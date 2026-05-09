"""Router pour l'analyse NLP des signaux sociaux (BERT)."""

from datetime import datetime
from typing import List

from fastapi import APIRouter, HTTPException, BackgroundTasks

from app.models.schemas import (
    SocialSignalRequest, 
    NLPAnalysisResponse,
    BatchNLPRequest,
    DisasterType
)
from app.services.ml_models import nlp_model
from app.services.queue import enqueue_social_signal

router = APIRouter()


@router.post("/analyze", response_model=NLPAnalysisResponse)
async def analyze_text(
    request: SocialSignalRequest,
    background_tasks: BackgroundTasks
):
    """
    Analyse un texte avec BERT pour détecter:
    - Type de catastrophe
    - Niveau d'urgence
    - Localisation mentionnée
    - Sentiment
    """
    try:
        result = await nlp_model.analyze(
            text=request.text,
            language=request.language,
            author_location_hint=request.author_location
        )
        
        response = NLPAnalysisResponse(
            disaster_type=result.get("disaster_type"),
            confidence=result["confidence"],
            urgency=result["urgency"],
            sentiment=result["sentiment"],
            keywords=result["keywords"],
            entities=result["entities"],
            location_mentioned=result.get("location"),
            processed_at=datetime.utcnow()
        )
        
        # Si urgence détectée avec confiance, sauvegarder
        if result["urgency"] in ["elevee", "critique"] and result["confidence"] > 0.7:
            background_tasks.add_task(
                enqueue_social_signal,
                text=request.text,
                platform=request.platform,
                analysis=result
            )
        
        return response
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Erreur NLP: {str(e)}")


@router.post("/analyze-batch")
async def analyze_batch(request: BatchNLPRequest):
    """
    Analyse batch de plusieurs textes (plus efficace).
    """
    try:
        results = await nlp_model.analyze_batch(
            texts=request.texts,
            batch_size=16
        )
        
        return {
            "results": results,
            "count": len(results),
            "high_urgency_count": sum(
                1 for r in results 
                if r.get("urgency") in ["elevee", "critique"]
            ),
            "processed_at": datetime.utcnow()
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Erreur batch NLP: {str(e)}")


@router.post("/stream/simulate")
async def simulate_stream_analysis(keywords: List[str] = None):
    """
    Simule l'analyse d'un stream Twitter/X pour démonstration.
    """
    if not keywords:
        keywords = ["inondation", "feu", "cyclone", "tremblement", "secours"]
    
    # Simulation de tweets
    sample_tweets = [
        "URGENT: Inondation massive à Antananarivo, besoin d'aide! #inondation",
        "Feu de forêt détecté près de Majunga, appelez les pompiers",
        "Tempête tropicale approche la côte est, restez à l'intérieur",
        "Tout va bien ici, belle journée ensoleillée",
        "Glissement de terrain route d'Antsirabe, circulation coupée"
    ]
    
    results = []
    for tweet in sample_tweets:
        result = await nlp_model.quick_analyze(tweet)
        results.append({
            "text": tweet,
            "analysis": result
        })
    
    # Filtrer les alertes pertinentes
    alerts = [r for r in results if r["analysis"]["urgency"] in ["elevee", "critique"]]
    
    return {
        "stream_analysis": results,
        "alerts_detected": alerts,
        "keywords_matched": keywords,
        "alert_count": len(alerts)
    }
