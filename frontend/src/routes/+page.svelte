<script lang="ts">
	import { onMount } from 'svelte'

	interface Board {
		id: number
		title: string
	}

	let boards: Board[]
	let newBoardTitle = ''

	async function fetchBoards() {
		const response = await fetch('http://localhost:3000/api/v1/boards')
		boards = await response.json()
	}

	async function createBoard() {
		await fetch('http://localhost:3000/api/v1/boards', {
			method: 'POST',
			headers: { 'Content-Type': 'application/json' },
			body: JSON.stringify({ board: { title: newBoardTitle } })
		})
		newBoardTitle = ''
		fetchBoards()
	}

	onMount(fetchBoards)
</script>

<h1>
	My Boards
</h1>

<input bind:value={newBoardTitle} placeholder="New board name" />
<button on:click={createBoard}>Create Board</button>

<div class="boards">
	{#each boards as board}
		<a href="/boards/{board.id}" class="board-card">
			<h3>{board.title}</h3>
		</a>
	{/each}
</div>

<style>
	.boards {
		display: grid;
		grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
		gap: 1rem;
		margin-top: 2rem;
	}

	.board-card {
		padding: 2rem;
		background: cadetblue;
		color: white;
		border-radius: 4px;
		cursor: pointer;
    	text-decoration: none;
		display: block;
	}
</style>
