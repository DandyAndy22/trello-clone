<script lang='ts'>
    import { onMount, onDestroy } from 'svelte';
    import { browser } from '$app/environment';
    
    export let isOpen = false;
    export let onClose = () => {};
    
    function handleEscape(event: KeyboardEvent) {
      if (event.key === 'Escape' && isOpen) {
        onClose();
      }
    }
    
    function handleBackdropClick(event: MouseEvent) {
      // Only close if clicking the backdrop itself, not its children
      if (event.target === event.currentTarget) {
        onClose();
      }
    }
    
    onMount(() => {
        if (browser) {
          document.addEventListener('keydown', handleEscape);
        }
    });
    
    onDestroy(() => {
      if (browser) {
        document.removeEventListener('keydown', handleEscape);
      }
    });
  </script>
  
  {#if isOpen}
    <div class="modal-backdrop" on:click={handleBackdropClick}>
      <div class="modal-content" on:click|stopPropagation>
        <button class="close-button" on:click={onClose} aria-label="Close modal">
          ×
        </button>
        <slot />
      </div>
    </div>
  {/if}
  
  <style>
    .modal-backdrop {
      position: fixed;
      top: 0;
      left: 0;
      right: 0;
      bottom: 0;
      background: rgba(0, 0, 0, 0.5);
      display: flex;
      justify-content: center;
      align-items: center;
      z-index: 1000;
      animation: fadeIn 0.2s ease-out;
    }
    
    @keyframes fadeIn {
      from {
        opacity: 0;
      }
      to {
        opacity: 1;
      }
    }
    
    .modal-content {
      background: white;
      border-radius: 8px;
      box-shadow: 0 8px 16px rgba(0, 0, 0, 0.3);
      max-width: 768px;
      width: 90%;
      max-height: 90vh;
      overflow-y: auto;
      position: relative;
      animation: slideUp 0.2s ease-out;
    }
    
    @keyframes slideUp {
      from {
        transform: translateY(20px);
        opacity: 0;
      }
      to {
        transform: translateY(0);
        opacity: 1;
      }
    }
    
    .close-button {
      position: absolute;
      top: 12px;
      right: 12px;
      background: none;
      border: none;
      font-size: 28px;
      line-height: 1;
      color: #5e6c84;
      cursor: pointer;
      padding: 4px 8px;
      border-radius: 4px;
      transition: all 0.2s;
      z-index: 1;
    }
    
    .close-button:hover {
      background: #091e4214;
      color: #172b4d;
    }
  </style>