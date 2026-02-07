<script lang="ts">
  import { onMount } from 'svelte';
  import { auth, logout } from '$lib/stores/auth';
  import { apiRequest } from '$lib/api';
  import { goto } from '$app/navigation';
  
  interface Board {
    id: number;
    title: string;
  }
  
  let boards: Board[] = [];
  let deletingBoardId: number | null = null
  let newBoardTitle = '';

  async function fetchBoards() {
    try {
      boards = await apiRequest('/boards');
    } catch (error) {
      console.error('Failed to fetch boards:', error);
    }
  }

  async function deleteBoard(boardId: number, event: MouseEvent) {
    event.preventDefault()
    event.stopPropagation()

    if (!confirm('Are you sure you want to delete this board?')) return

    deletingBoardId = boardId;

    try {
      await apiRequest(`/boards/${boardId}`, {
        method: 'DELETE',
      })
      await fetchBoards()
    } catch (error) {
      console.error('Failed to delete board:', error)
      alert('Failed to delete board.')
    } finally {
      deletingBoardId = null
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
    if (!$auth) {
      goto('/login');
    } else {
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
        <div class="board-card-container">
          <a href="/boards/{board.id}" class="board-card">
            <h3>{board.title}</h3>
          </a>
          <button 
            class="delete-board-button"
            on:click={(e) => deleteBoard(board.id, e)}
            disabled={deletingBoardId === board.id}
            title="Delete board"
          >
            {deletingBoardId === board.id ? '...' : '×'}
          </button>
        </div>
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
  
  .board-card-container {
    position: relative;
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

  .delete-board-button {
    position: absolute;
    top: 8px;
    right: 8px;
    background: none;
    border: none;
    color: rgba(255, 255, 255, 0.7);
    font-size: 20px;
    line-height: 1;
    cursor: pointer;
    padding: 4px 8px;
    border-radius: 4px;
    opacity: 0;
    transition: all 0.2s;
    z-index: 1;
  }

  .board-card-container:hover .delete-board-button {
    opacity: 1;
  }

  .delete-board-button:hover:not(:disabled) {
    background: rgba(0, 0, 0, 0.2);
    color: #eb5a46;
  }

  .delete-board-button:disabled {
    cursor: not-allowed;
    opacity: 0.5;
  }
</style>