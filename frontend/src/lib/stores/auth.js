import { writable } from 'svelte/store'
import { browser } from '$app/environment'

const getStoredAuth = () => {
    if (!browser) return null

    const token = localStorage.getItem('authToken')
    const user = localStorage.getItem('authUser')

    return token && user ? { token, user: JSON.parse(user) } : null
}

export const auth = writable(getStoredAuth())

export const login = async (email, password) => {
    const response = await fetch('http://localhost:3000/api/v1/login', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({ email, password })
    })

    if (!response.ok) {
        const error = await response.json()
        throw new Error(error.message || 'Login failed')
    }

    const data = await response.json()
    localStorage.setItem('authToken', data.token)
    localStorage.setItem('authUser', JSON.stringify(data.user))
    auth.set({ token: data.token, user: data.user })
    return data
}

export const signup = async (name, email, password, passwordConfirmation) => {
    const response = await fetch('http://localhost:3000/api/v1/signup', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({ name, email, password, password_confirmation: passwordConfirmation })
    })

    if (!response.ok) {
        const error = await response.json()
        throw new Error(error.errors?.join(', ') || 'Signup failed')
    }

    const data = await response.json()
    localStorage.setItem('authToken', data.token)
    localStorage.setItem('authUser', JSON.stringify(data.user))
    auth.set({ token: data.token, user: data.user })
    return data
}

export const logout = () => {
    localStorage.removeItem('authToken')
    localStorage.removeItem('authUser')
    auth.set(null)
}