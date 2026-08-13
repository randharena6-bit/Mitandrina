"""Router pour le traitement des simulations cycloniques côté Python."""

import json
import asyncio
from datetime import datetime, timezone
from typing import Optional

from fastapi import APIRouter, HTTPException
from pydantic import BaseModel

from app.services.simulation_engine import run_simulation
from app.core.database import SessionLocal


router = APIRouter()


class RunSimulationRequest(BaseModel):
    simulation_id: str
    name: str
    scenario_type: str = "cyclone"
    center_lat: float = -18.9078
    center_lng: float = 47.5208
    intensity_level: int = 5
    radius_km: float = 10.0


@router.post("/simulations/run", summary="Lancer le calcul d'une simulation")
async def run_sim(req: RunSimulationRequest):
    try:
        result = await run_simulation(req.model_dump())

        db = SessionLocal()
        try:
            db.execute(
                __import__('sqlalchemy').text("""
                    UPDATE simulations
                    SET status = 'completed',
                        completed_at = NOW(),
                        execution_time_seconds = 2,
                        evacuation_routes_generated = :routes_count,
                        estimated_evacuation_time_minutes = :evac_time,
                        results = :results::jsonb
                    WHERE id = :sim_id
                """),
                {
                    "sim_id": req.simulation_id,
                    "routes_count": len(result.get("evacuation_routes", [])),
                    "evac_time": result.get("estimated_evacuation_time_minutes", 60),
                    "results": json.dumps(result, ensure_ascii=False, default=str)
                }
            )
            db.commit()
        except Exception as db_err:
            db.rollback()
            raise HTTPException(status_code=500, detail=f"Erreur DB: {str(db_err)}")
        finally:
            db.close()

        return {"success": True, "simulation_id": req.simulation_id}

    except Exception as e:
        db = SessionLocal()
        try:
            db.execute(
                __import__('sqlalchemy').text(
                    "UPDATE simulations SET status = 'failed', error_message = :err WHERE id = :sim_id"
                ),
                {"sim_id": req.simulation_id, "err": str(e)}
            )
            db.commit()
        except Exception:
            db.rollback()
        finally:
            db.close()
        raise HTTPException(status_code=500, detail=f"Erreur simulation: {str(e)}")


@router.post("/simulations/run-async", summary="Lancer simulation en arriere-plan")
async def run_sim_async(req: RunSimulationRequest):
    asyncio.create_task(_process_in_background(req))
    return {"success": True, "simulation_id": req.simulation_id, "status": "processing"}


async def _process_in_background(req: RunSimulationRequest):
    try:
        result = await run_simulation(req.model_dump())
        db = SessionLocal()
        try:
            db.execute(
                __import__('sqlalchemy').text("""
                    UPDATE simulations
                    SET status = 'completed',
                        completed_at = NOW(),
                        execution_time_seconds = 2,
                        evacuation_routes_generated = :routes_count,
                        estimated_evacuation_time_minutes = :evac_time,
                        results = :results::jsonb
                    WHERE id = :sim_id
                """),
                {
                    "sim_id": req.simulation_id,
                    "routes_count": len(result.get("evacuation_routes", [])),
                    "evac_time": result.get("estimated_evacuation_time_minutes", 60),
                    "results": json.dumps(result, ensure_ascii=False, default=str)
                }
            )
            db.commit()
        except Exception:
            db.rollback()
        finally:
            db.close()
    except Exception as e:
        db = SessionLocal()
        try:
            db.execute(
                __import__('sqlalchemy').text(
                    "UPDATE simulations SET status = 'failed', error_message = :err WHERE id = :sim_id"
                ),
                {"sim_id": req.simulation_id, "err": str(e)}
            )
            db.commit()
        except Exception:
            db.rollback()
        finally:
            db.close()


@router.get("/simulations/{sim_id}/status", summary="Statut d'une simulation")
async def get_simulation_status(sim_id: str):
    db = SessionLocal()
    try:
        result = db.execute(
            __import__('sqlalchemy').text(
                "SELECT id, status, results, execution_time_seconds, evacuation_routes_generated, estimated_evacuation_time_minutes, error_message FROM simulations WHERE id = :sim_id"
            ),
            {"sim_id": sim_id}
        ).fetchone()
        if not result:
            raise HTTPException(status_code=404, detail="Simulation introuvable")
        return {
            "simulation_id": result[0],
            "status": result[1],
            "results": result[2],
            "execution_time_seconds": result[3],
            "evacuation_routes_generated": result[4],
            "estimated_evacuation_time_minutes": result[5],
            "error_message": result[6]
        }
    finally:
        db.close()


@router.post("/simulations/generate-trajectory", summary="Generer trajectoire sans sauvegarder")
async def generate_trajectory_only(
    lat: float = -18.9,
    lng: float = 47.5,
    intensity: int = 5,
    hours: int = 168,
    step: int = 6
):
    from app.services.simulation_engine import generate_trajectory
    track = generate_trajectory(lat, lng, intensity, hours, step)
    return {"track": track, "count": len(track)}
