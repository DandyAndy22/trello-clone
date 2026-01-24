<script lang='ts'>
    import { onMount } from 'svelte'
    import { page } from '$app/stores'
    import { flip } from 'svelte/animate'
    import { dndzone } from 'svelte-dnd-action'

    interface Board {
        id: number
        title: string
        lists: List[]
    }

    interface Card {
        id: number
        title: string
        position: number
        list_id: number
    }

    interface List {
        id: number
        title: string
        cards?: Card[]
    }

    let board: Board | null = null
    let lists: List[] = []
    let newListTitle = ''
    let newCardTitles: Record<number, string> = {}

    const flipDurationMs: number = 200

    $: boardId = $page.params.id

    async function fetchBoard() {
        const response = await fetch(`http://localhost:3000/api/v1/boards/${boardId}`)
        board = await response.json()
        lists = board?.lists || []

        lists = lists.map(list => ({
          ...list,
          cards: (list.cards || []).map(card => ({ ...card, id: card.id }))
        }))
    }

    async function createList() {
        if(!newListTitle.trim()) return

        await fetch(`http://localhost:3000/api/v1/boards/${boardId}/lists`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ list: { title: newListTitle } })
        })

        newListTitle = ''
        fetchBoard()
    }

    async function createCard(listId: number) {
      const title = newCardTitles[listId]
      if(!title.trim()) return

      await fetch(`http://localhost:3000/api/v1/lists/${listId}/cards`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ card: { title } })
      })

      newCardTitles[listId] = ''
      fetchBoard()
    }

    async function updateCard(cardId: number, updates: Partial<Card>) {
      await fetch(`http://localhost:3000/api/v1/cards/${cardId}`, {
          method: 'PATCH',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ card: updates })
      })
    }

    function handleDndConsider(listId: number, event: any) {
      const listIndex = lists.findIndex(l => l.id === listId)
      lists[listIndex].cards = event.detail.items
      lists = [...lists] // Trigger reactivity
    }

    function handleDndFinalize(listId: number, event: any) {
      const listIndex = lists.findIndex(l => l.id === listId)
      lists[listIndex].cards = event.detail.items
      lists = [...lists] // Trigger reactivity

      // Update card positions in the backend
      const cards = event.detail.items
      cards.forEach((card: Card, index: number) => {
        updateCard(card.id, { position: index, list_id: listId })
      })
    }

    onMount(fetchBoard)
</script>

{#if board}
  <div class="board-header">
    <h1>{board.title}</h1>
  </div>

  <div class="lists-container">
    {#each lists as list}
      <div class="list">
        <h3>{list.title}</h3>

        <div
          class="cards"
          use:dndzone={{items: list.cards || [], flipDurationMs}}
          on:consider={(e) => handleDndConsider(list.id, e)}
          on:finalize={(e) => handleDndFinalize(list.id, e)}
        >
          {#each list.cards || [] as card (card.id)}
            <div class="card" animate:flip={{ duration: flipDurationMs }}>
              {card.title}
            </div>
          {/each}
        </div>

        <div class="add-card">
            <input 
              bind:value={newCardTitles[list.id]} 
              placeholder="Enter card title..."
              on:keydown={(e) => e.key === 'Enter' && createCard(list.id)}
            />
            <button on:click={() => createCard(list.id)}>Add Card</button>
        </div>
      </div>
    {/each}
    
    <div class="list add-list">
      <input 
        bind:value={newListTitle} 
        placeholder="Enter list title..."
        on:keydown={(e) => e.key === 'Enter' && createList()}
      />
      <button on:click={createList}>Add List</button>
    </div>
  </div>
{:else}
  <p>Loading...</p>
{/if}

<style>
  :global(body) {
    background: floralwhite;
    margin: 0;
  }

  .board-header {
    padding: 1rem 2rem;
    background: rgba(0, 0, 0, 0.2);
  }

  .board-header h1 {
    color: white;
    margin: 0;
  }

  .lists-container {
    display: flex;
    gap: 1rem;
    padding: 1rem;
    overflow-x: auto;
    height: calc(100vh - 100px);
  }

  .list {
    background: #ebecf0;
    border-radius: 8px;
    padding: 0.5rem;
    min-width: 272px;
    max-width: 272px;
    max-height: fit-content;
  }

  .list h3 {
    margin: 0.5rem;
    font-size: 14px;
    font-weight: 600;
  }

  .add-list {
    background: rgba(255, 255, 255, 0.2);
    display: flex;
    flex-direction: column;
    gap: 0.5rem;
  }

  .add-list input {
    padding: 0.5rem;
    border: none;
    border-radius: 4px;
  }

  .add-list button {
    padding: 0.5rem;
    background: #0079bf;
    color: white;
    border: none;
    border-radius: 4px;
    cursor: pointer;
  }

  .cards {
    display: flex;
    flex-direction: column;
    gap: 0.5rem;
    margin-bottom: 0.5rem;
    min-height: 50px;
  }

  .card {
    background: white;
    padding: 0.75rem;
    border-radius: 4px;
    box-shadow: 0 1px 0 rgba(9, 30, 66, 0.25);
    cursor: grab;
  }

  .card:active {
    cursor: grabbing;
  }

  .card:hover {
    background: #f4f5f7;
  }

  .add-card {
    display: flex;
    flex-direction: column;
    gap: 0.5rem;
    margin-top: 0.5rem;
  }

  .add-card input {
    padding: 0.5rem;
    border: none;
    border-radius: 4px;
    font-size: 14px;
  }

  .add-card button {
    padding: 0.5rem;
    background: #0079bf;
    color: white;
    border: none;
    border-radius: 4px;
    cursor: pointer;
    font-size: 14px;
  }
</style>