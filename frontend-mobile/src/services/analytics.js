// 🌪️ MITANDRINA - Analytics service
/**
 * Service simple d'analytics (à remplacer par Amplitude, Segment etc)
 */

class AnalyticsService {
  constructor() {
    this.events = [];
  }

  /**
   * Track un événement
   */
  trackEvent = (eventName, properties = {}) => {
    const event = {
      name: eventName,
      properties,
      timestamp: new Date().toISOString(),
    };

    this.events.push(event);
    console.log("[Analytics]", eventName, properties);

    // TODO: Envoyer au backend ou service analytics
    // this.sendToBackend(event);
  };

  /**
   * Track une vue
   */
  trackScreenView = (screenName) => {
    this.trackEvent("screen_view", { screen: screenName });
  };

  /**
   * Track une action utilisateur
   */
  trackUserAction = (action, metadata = {}) => {
    this.trackEvent(`user_${action}`, metadata);
  };

  /**
   * Track une erreur
   */
  trackError = (error, context = {}) => {
    this.trackEvent("error", {
      message: error.message,
      stack: error.stack,
      ...context,
    });
  };

  /**
   * Envoyer les événements au backend
   */
  flush = async () => {
    if (this.events.length === 0) return true;

    try {
      // TODO: Implémenter l'envoi au backend
      console.log(`[Analytics] Flush ${this.events.length} events`);
      this.events = [];
      return true;
    } catch (error) {
      console.error("Erreur flush analytics:", error);
      return false;
    }
  };
}

export default new AnalyticsService();
