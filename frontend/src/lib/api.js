import { get } from 'svelte/store'
import { auth } from './stores/auth'

const BASE_URL = 'http://localhost:3000/api/v1'

export async function apiRequest(endpoint, options = {}) {
    const authData = get(auth)
    const token = authData?.token || null

    const config = {
        ...options,
        headers: {
            'Content-Type': 'application/json',
            ...(token && { 'Authorization': `Bearer ${token}` }),
            ...options.headers
        }
    }
    
    const response = await fetch(`${BASE_URL}${endpoint}`, config)

    if (!response.ok && response.status === 401) {
        // Token might be invalid or expired
        const { logout } = await import('./stores/auth')
        logout()
        throw new Error('Session expired. Please log in again.')
    }
    return response.json()
}