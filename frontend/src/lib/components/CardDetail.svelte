<script lang='ts'>
    import { apiRequest } from '$lib/api';

    interface Card {
        id: number;
        title: string;
        description?: string | null;
        due_date?: string | null;
    }
    
    export let card: Card | null = null;
    export let onClose = () => {};
    export let onSave = () => {};
    
    let title = card?.title;
    let description = card?.description;
    let dueDate = card?.due_date;
    let saving = false;
    let error = '';
    
    async function handleSave() {
      if (!title?.trim()) {
        error = 'Title is required';
        return;
      }
      
      saving = true;
      error = '';
      
      try {
        await apiRequest(`/cards/${card?.id}`, {
          method: 'PATCH',
          body: JSON.stringify({
            card: {
              title,
              description,
              due_date: dueDate || null
            }
          })
        });
        
        onSave();
        onClose();
      } catch (e) {
        error = 'Failed to save card';
      } finally {
        saving = false;
      }
    }
  
    function handleKeydown(e: KeyboardEvent) {
      if (e.key === 'Enter' && (e.metaKey || e.ctrlKey)) {
        handleSave();
      }
    }
  </script>
  
  <!-- svelte-ignore a11y_no_static_element_interactions -->
  <div class="card-detail" on:keydown={handleKeydown}>
    <div class="card-detail-body">
      <div class="field">
        <label for="title">Title</label>
        <input
          id="title"
          type="text"
          bind:value={title}
          placeholder="Card title"
          autofocus
        />
      </div>
      
      <div class="field">
        <label for="description">Description</label>
        <!-- svelte-ignore element_invalid_self_closing_tag -->
        <textarea
          id="description"
          bind:value={description}
          placeholder="Add a description..."
          rows="5"
        />
      </div>
      
      <div class="field">
        <label for="due-date">Due Date</label>
        <input
          id="due-date"
          type="date"
          bind:value={dueDate}
        />
      </div>
      
      {#if error}
        <div class="error">{error}</div>
      {/if}
      
      <div class="actions">
        <button class="save-button" on:click={handleSave} disabled={saving}>
          {saving ? 'Saving...' : 'Save (⌘ + Enter)'}
        </button>
        <button class="cancel-button" on:click={onClose}>
          Cancel
        </button>
      </div>
    </div>
  </div>
  
  <style>
    .card-detail {
      padding: 2rem;
      min-height: 300px;
    }
  
    .card-detail-body {
      display: flex;
      flex-direction: column;
      gap: 1.25rem;
    }
  
    .field {
      display: flex;
      flex-direction: column;
      gap: 0.5rem;
    }
  
    label {
      font-size: 12px;
      font-weight: 600;
      text-transform: uppercase;
      color: #5e6c84;
      letter-spacing: 0.04em;
    }
  
    input[type="text"],
    input[type="date"],
    textarea {
      padding: 0.75rem;
      border: 2px solid #dfe1e6;
      border-radius: 4px;
      font-size: 14px;
      font-family: inherit;
      color: #172b4d;
      transition: border-color 0.2s;
      resize: vertical;
    }
  
    input[type="text"]:focus,
    input[type="date"]:focus,
    textarea:focus {
      outline: none;
      border-color: #0079bf;
    }
  
    .error {
      background: #eb5a46;
      color: white;
      padding: 0.75rem;
      border-radius: 4px;
      font-size: 14px;
    }
  
    .actions {
      display: flex;
      gap: 0.5rem;
      align-items: center;
      padding-top: 0.5rem;
    }
  
    .save-button {
      padding: 0.75rem 1.5rem;
      background: #0079bf;
      color: white;
      border: none;
      border-radius: 4px;
      font-size: 14px;
      font-weight: 600;
      cursor: pointer;
      transition: background 0.2s;
    }
  
    .save-button:hover:not(:disabled) {
      background: #026aa7;
    }
  
    .save-button:disabled {
      opacity: 0.6;
      cursor: not-allowed;
    }
  
    .cancel-button {
      padding: 0.75rem 1.5rem;
      background: none;
      color: #5e6c84;
      border: none;
      border-radius: 4px;
      font-size: 14px;
      font-weight: 600;
      cursor: pointer;
      transition: background 0.2s;
    }
  
    .cancel-button:hover {
      background: #091e4214;
      color: #172b4d;
    }
  </style>