import { useState, useEffect } from 'react'
import axios from 'axios'
import './App.css'

const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || ''

function App() {
  const [backendHealth, setBackendHealth] = useState(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState(null)

  useEffect(() => {
    const checkBackendHealth = async () => {
      try {
        setLoading(true)
        const response = await axios.get(`${API_BASE_URL}/api/v1/health`)
        setBackendHealth(response.data)
        setError(null)
      } catch (err) {
        setError(err.message)
        setBackendHealth(null)
      } finally {
        setLoading(false)
      }
    }

    checkBackendHealth()
    const interval = setInterval(checkBackendHealth, 30000) // Check every 30s
    return () => clearInterval(interval)
  }, [])

  return (
    <div className="App">
      <header className="App-header">
        <h1>FastAPI React Postgres Template</h1>
        <p>Production-ready full-stack application</p>
      </header>

      <main className="App-main">
        <div className="status-card">
          <h2>Backend Status</h2>
          {loading ? (
            <p>Checking backend health...</p>
          ) : error ? (
            <div className="status-error">
              <p>Backend is unreachable</p>
              <p className="error-message">{error}</p>
            </div>
          ) : backendHealth ? (
            <div className="status-success">
              <p>Status: <strong>{backendHealth.status}</strong></p>
              <p>Database: <strong>{backendHealth.database}</strong></p>
              <p>Timestamp: {new Date(backendHealth.timestamp).toLocaleString()}</p>
            </div>
          ) : null}
        </div>

        <div className="info-card">
          <h2>Stack</h2>
          <ul>
            <li>Frontend: React + Vite</li>
            <li>Backend: FastAPI</li>
            <li>Database: PostgreSQL</li>
            <li>Deployment: Docker Compose</li>
          </ul>
        </div>

        <div className="info-card">
          <h2>Features</h2>
          <ul>
            <li>Health check endpoints</li>
            <li>CORS configuration</li>
            <li>Database migrations (Alembic)</li>
            <li>Production Docker setup</li>
            <li>Environment-based configuration</li>
          </ul>
        </div>
      </main>

      <footer className="App-footer">
        <p>API Base URL: {API_BASE_URL}</p>
      </footer>
    </div>
  )
}

export default App
