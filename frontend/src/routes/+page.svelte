<script>
  import { onMount } from 'svelte';
  import { auth, logout } from '$lib/stores/auth';
  import { apiRequest } from '$lib/api';
  import { goto } from '$app/navigation';
  
  let boards = [];
  let newBoardTitle = '';
  
  $: if (!$auth) {
    goto('/login');
  }

  async function fetchBoards() {
    try {
      const response = await apiRequest('/boards');
      boards = await response.json();
    } catch (error) {
      console.error('Failed to fetch boards:', error);
    }
  }

  async function createBoard() {
    try {
      await apiRequest('/boards', {
        method: 'POST',
        body: JSON.stringify({ board: { title: newBoardTitle } })
      });
      newBoardTitle = '';
      fetchBoards();
    } catch (error) {
      console.error('Failed to create board:', error);
    }
  }

  function handleLogout() {
    logout();
    goto('/login');
  }

  onMount(() => {
    if ($auth) {
      fetchBoards();
    }
  });
</script>

{#if $auth}
  <div class="header">
    <h1>My Boards</h1>
    <div class="user-info">
      <span>Welcome, {$auth.user.name}</span>
      <button on:click={handleLogout}>Logout</button>
    </div>
  </div>

  <div class="container">
    <div class="create-board">
      <input bind:value={newBoardTitle} placeholder="New board name" />
      <button on:click={createBoard}>Create Board</button>
    </div>

    <div class="boards">
      {#each boards as board}
        <a href="/boards/{board.id}" class="board-card">
          <h3>{board.title}</h3>
        </a>
      {/each}
    </div>
  </div>
{/if}

<style>
  :global(body) {
    margin: 0;
    background: #fafbfc;
  }

  .header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 1rem 2rem;
    background: white;
    border-bottom: 1px solid #dfe1e6;
  }

  .header h1 {
    margin: 0;
    color: #172b4d;
  }

  .user-info {
    display: flex;
    align-items: center;
    gap: 1rem;
  }

  .user-info span {
    color: #5e6c84;
  }

  .user-info button {
    padding: 0.5rem 1rem;
    background: #0079bf;
    color: white;
    border: none;
    border-radius: 4px;
    cursor: pointer;
  }

  .container {
    padding: 2rem;
  }

  .create-board {
    display: flex;
    gap: 1rem;
    margin-bottom: 2rem;
  }

  .create-board input {
    flex: 1;
    padding: 0.75rem;
    border: 2px solid #dfe1e6;
    border-radius: 4px;
    font-size: 14px;
  }

  .create-board button {
    padding: 0.75rem 1.5rem;
    background: #0079bf;
    color: white;
    border: none;
    border-radius: 4px;
    cursor: pointer;
    font-weight: 600;
  }

  .boards {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
    gap: 1rem;
  }
  
  .board-card {
    padding: 2rem;
    background: #0079bf;
    color: white;
    border-radius: 4px;
    cursor: pointer;
    text-decoration: none;
    display: block;
  }

  .board-card:hover {
    background: #026aa7;
  }

  .board-card h3 {
    margin: 0;
  }
</style>