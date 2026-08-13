// 🌪️ MITANDRINA - Hook pour les appels API
import { useState, useEffect, useCallback } from "react";
import api from "../services/api";

/**
 * Hook pour fetcher des données avec gestion d'erreur et loading
 * @param {Function} apiFn - Fonction d'appel API
 * @param {Array} dependencies - Dépendances pour relancer l'appel
 */
export const useFetch = (apiFn, dependencies = []) => {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [refetch, setRefetch] = useState(0);

  useEffect(() => {
    const fetchData = async () => {
      try {
        setLoading(true);
        setError(null);
        const response = await apiFn();
        setData(response.data);
      } catch (err) {
        setError(
          err.response?.data?.message ||
            "Erreur lors du chargement des données",
        );
        console.error("Erreur fetch:", err);
      } finally {
        setLoading(false);
      }
    };

    fetchData();
  }, [...dependencies, refetch]);

  const retry = useCallback(() => {
    setRefetch((prev) => prev + 1);
  }, []);

  return { data, loading, error, retry };
};

/**
 * Hook pour les données paginées
 */
export const usePaginatedFetch = (apiFn, pageSize = 20) => {
  const [items, setItems] = useState([]);
  const [page, setPage] = useState(1);
  const [loading, setLoading] = useState(false);
  const [hasMore, setHasMore] = useState(true);
  const [error, setError] = useState(null);

  const loadMore = useCallback(async () => {
    if (loading || !hasMore) return;

    try {
      setLoading(true);
      const response = await apiFn({ page, limit: pageSize });
      const newItems = response.data?.data || [];

      if (newItems.length === 0) {
        setHasMore(false);
      } else {
        setItems((prev) => [...prev, ...newItems]);
        setPage((prev) => prev + 1);
      }
    } catch (err) {
      setError(err.message);
      console.error("Erreur pagination:", err);
    } finally {
      setLoading(false);
    }
  }, [page, loading, hasMore, apiFn, pageSize]);

  useEffect(() => {
    loadMore();
  }, []);

  const reset = useCallback(() => {
    setItems([]);
    setPage(1);
    setHasMore(true);
  }, []);

  return { items, loading, error, hasMore, loadMore, reset };
};

/**
 * Hook pour gérer les états de formulaire
 */
export const useForm = (initialValues, onSubmit) => {
  const [values, setValues] = useState(initialValues);
  const [errors, setErrors] = useState({});
  const [loading, setLoading] = useState(false);

  const handleChange = useCallback(
    (name, value) => {
      setValues((prev) => ({ ...prev, [name]: value }));
      // Effacer l'erreur quand l'utilisateur corrige
      if (errors[name]) {
        setErrors((prev) => {
          const newErrors = { ...prev };
          delete newErrors[name];
          return newErrors;
        });
      }
    },
    [errors],
  );

  const handleSubmit = useCallback(async () => {
    try {
      setLoading(true);
      setErrors({});
      await onSubmit(values);
    } catch (error) {
      if (error.validationErrors) {
        setErrors(error.validationErrors);
      } else {
        setErrors({ submit: error.message });
      }
    } finally {
      setLoading(false);
    }
  }, [values, onSubmit]);

  const reset = useCallback(() => {
    setValues(initialValues);
    setErrors({});
  }, [initialValues]);

  return { values, errors, loading, handleChange, handleSubmit, reset };
};

/**
 * Hook pour les appels API avec debounce (utile pour recherche)
 */
export const useDebouncedFetch = (searchFn, delay = 500) => {
  const [query, setQuery] = useState("");
  const [results, setResults] = useState([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  useEffect(() => {
    if (!query.trim()) {
      setResults([]);
      return;
    }

    const timeoutId = setTimeout(async () => {
      try {
        setLoading(true);
        setError(null);
        const response = await searchFn(query);
        setResults(response.data?.data || []);
      } catch (err) {
        setError(err.message);
        setResults([]);
      } finally {
        setLoading(false);
      }
    }, delay);

    return () => clearTimeout(timeoutId);
  }, [query, searchFn, delay]);

  return { query, setQuery, results, loading, error };
};

export default useFetch;
