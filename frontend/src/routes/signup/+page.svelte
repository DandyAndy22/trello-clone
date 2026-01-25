<script>
  import { signup } from '$lib/stores/auth';
  import { goto } from '$app/navigation';
  
  let name = '';
  let email = '';
  let password = '';
  let passwordConfirmation = '';
  let error = '';
  let loading = false;
  
  async function handleSignup() {
    error = '';
    
    if (password !== passwordConfirmation) {
      error = 'Passwords do not match';
      return;
    }
    
    loading = true;
    
    try {
      await signup(name, email, password, passwordConfirmation);
      goto('/');
    } catch (e) {
      error = e.message;
    } finally {
      loading = false;
    }
  }
</script>

<div class="auth-container">
  <div class="auth-card">
    <h1>Sign Up for Trello Clone</h1>
    
    {#if error}
      <div class="error">{error}</div>
    {/if}
    
    <form on:submit|preventDefault={handleSignup}>
      <input 
        type="text" 
        bind:value={name} 
        placeholder="Full Name"
        required
      />
      
      <input 
        type="email" 
        bind:value={email} 
        placeholder="Email"
        required
      />
      
      <input 
        type="password" 
        bind:value={password} 
        placeholder="Password (min 6 characters)"
        required
        minlength="6"
      />
      
      <input 
        type="password" 
        bind:value={passwordConfirmation} 
        placeholder="Confirm Password"
        required
      />
      
      <button type="submit" disabled={loading}>
        {loading ? 'Creating account...' : 'Sign Up'}
      </button>
    </form>
    
    <p>
      Already have an account? 
      <a href="/login">Login</a>
    </p>
  </div>
</div>

<style>
  .auth-container {
    display: flex;
    justify-content: center;
    align-items: center;
    min-height: 100vh;
    background: #0079bf;
  }
  
  .auth-card {
    background: white;
    padding: 2rem;
    border-radius: 8px;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
    width: 100%;
    max-width: 400px;
  }
  
  h1 {
    margin: 0 0 1.5rem 0;
    text-align: center;
    color: #172b4d;
    font-size: 1.5rem;
  }
  
  form {
    display: flex;
    flex-direction: column;
    gap: 1rem;
  }
  
  input {
    padding: 0.75rem;
    border: 2px solid #dfe1e6;
    border-radius: 4px;
    font-size: 14px;
  }
  
  input:focus {
    outline: none;
    border-color: #0079bf;
  }
  
  button {
    padding: 0.75rem;
    background: #0079bf;
    color: white;
    border: none;
    border-radius: 4px;
    font-size: 14px;
    font-weight: 600;
    cursor: pointer;
  }
  
  button:hover:not(:disabled) {
    background: #026aa7;
  }
  
  button:disabled {
    opacity: 0.6;
    cursor: not-allowed;
  }
  
  .error {
    background: #eb5a46;
    color: white;
    padding: 0.75rem;
    border-radius: 4px;
    margin-bottom: 1rem;
  }
  
  p {
    text-align: center;
    margin-top: 1rem;
    color: #5e6c84;
  }
  
  a {
    color: #0079bf;
    text-decoration: none;
  }
  
  a:hover {
    text-decoration: underline;
  }
</style>