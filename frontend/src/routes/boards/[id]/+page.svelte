<script lang='ts'>
    import { onMount } from 'svelte'
    import { page } from '$app/stores'
    import { flip } from 'svelte/animate'
    import { dndzone } from 'svelte-dnd-action'
    import { apiRequest } from '$lib/api';
    import { auth } from '$lib/stores/auth';
    import { goto } from '$app/navigation';
    import { browser } from '$app/environment';
    import Modal from '$lib/components/Modal.svelte';
    import CardDetail from '$lib/components/CardDetail.svelte';

    interface Board {
        id: number
        title: string
        lists: List[]
    }

    interface Card {
        id: number
        title: string
        position: number
        description?: string | null
        due_date?: string | null
        list_id: number
    }

    interface List {
        id: number
        title: string
        cards?: Card[]
    }

    // Check auth
    $: if (browser && !$auth) {
      goto('/login');
    }

    let board: Board | null = null
    let deletingListId: number | null = null
    let lists: List[] = []
    let newListTitle = ''
    let newCardTitles: Record<number, string> = {}

    // Modal state
    let showCardModal = false;
    let selectedCardId: number | null = null
    let selectedCard: Card | null = null
    let isLoadingCard = false
    let isEditingCard = false

    const flipDurationMs: number = 200

    $: boardId = $page.params.id

    function openCard(card: Card) {
      selectedCard = card;
      showCardModal = true;
    }

    function closeCard() {
      selectedCard = null;
      showCardModal = false;
    }

    async function fetchBoard() {
      try {
        const boardData = await apiRequest(`/boards/${boardId}`);
        board = boardData;
        lists = boardData.lists || [];
        
        lists = lists.map(list => ({
          ...list,
          cards: (list.cards || []).map(card => ({ ...card, id: card.id }))
        }));
      } catch (error) {
        console.error('Failed to fetch board:', error);
      }
    }

    // List operations

    async function createList() {
      if (!newListTitle.trim()) return;
  
      try {
        await apiRequest(`/boards/${boardId}/lists`, {
          method: 'POST',
          body: JSON.stringify({ list: { title: newListTitle } })
        });
        
        newListTitle = '';
        fetchBoard();
      } catch (error) {
        console.error('Failed to create list:', error);
      }
    }

    async function deleteList(listId: number) {
      if (!confirm('Are you sure you want to delete this list?')) return

      deletingListId = listId;

      try {
        await apiRequest(`/lists/${listId}`, {
          method: 'DELETE',
        })
        await fetchBoard()
      } catch (error) {
        console.error('Failed to delete list:', error)
        alert('Failed to delete list.')
      } finally {
        deletingListId = null
      }
    }

    // Card operations

    async function createCard(listId: number) {
      const title = newCardTitles[listId];
      if (!title?.trim()) return;
      
      try {
        await apiRequest(`/lists/${listId}/cards`, {
          method: 'POST',
          body: JSON.stringify({ card: { title } })
        });
        
        newCardTitles[listId] = '';
        fetchBoard();
      } catch (error) {
        console.error('Failed to create card:', error);
      }
    }

    async function updateCard(cardId: number, updates: Partial<Card>) {
      try {
        await apiRequest(`/cards/${cardId}`, {
          method: 'PATCH',
          body: JSON.stringify({ card: updates })
        });
      } catch (error) {
        console.error('Failed to update card:', error);
      }
    }

    // Card Modal

    async function openCardModal(cardId: number) {
      isLoadingCard = true
      selectedCardId = cardId

      try {
        const cardData = await apiRequest(`/cards/${cardId}`)
        selectedCard = cardData
      } catch (error) {
        console.error('Failed to fetch card:', error)
      } finally {
        isLoadingCard = false
      }
    }

    async function closeCardModal() {
      selectedCardId = null
      selectedCard = null
      isEditingCard = false
    }
    
    async function deleteCard(cardId: number) {
      if (!confirm('Are you sure you want to delete this card?')) return

      try {
        await apiRequest(`/cards/${cardId}`, {
          method: 'DELETE',
        })
        await fetchBoard()
        closeCardModal()
      } catch (error) {
        console.error('Failed to delete card:', error)
        alert('Failed to delete card.')
      }
    }

    // DnD operations

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
        <button 
            class="delete-list-button"
            on:click={() => deleteList(list.id)}
            disabled={deletingListId === list.id}
            title="Delete list"
          >
            {deletingListId === list.id ? '...' : '×'}
          </button>
        <div
          class="cards"
          use:dndzone={{items: list.cards || [], flipDurationMs}}
          on:consider={(e) => handleDndConsider(list.id, e)}
          on:finalize={(e) => handleDndFinalize(list.id, e)}
        >
          {#each list.cards || [] as card (card.id)}
            <div 
              class="card" 
              animate:flip={{ duration: flipDurationMs }}
              on:click={() => openCard(card)}
              role="button"
              tabindex="0"
              aria-label="View card"
              on:keydown={(e) => e.key === 'Enter' && openCard(card)}
            >
              {card.title}
              {#if card.due_date}
                <span class="due-date">📅 {card.due_date}</span>
              {/if}
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

<Modal isOpen={showCardModal} onClose={closeCard}>
  {#if selectedCard}
    <CardDetail 
      card={selectedCard}
      onClose={closeCard}
      onSave={fetchBoard}
    />
  {/if}
</Modal>

<style>
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

  .delete-list-button {
    background: none;
    border: none;
    color: #5e6c84;
    font-size: 20px;
    line-height: 1;
    cursor: pointer;
    padding: 4px 8px;
    border-radius: 4px;
    opacity: 0;
    transition: all 0.2s;
  }

  .list:hover .delete-list-button {
    opacity: 1;
  }

  .delete-list-button:hover:not(:disabled) {
    background: #091e4214;
    color: #eb5a46;
  }

  .delete-list-button:disabled {
    cursor: not-allowed;
    opacity: 0.5;
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

  .due-date {
    font-size: 12px;
    color: #5e6c84;
    margin-top: 0.5rem;
  }
</style>