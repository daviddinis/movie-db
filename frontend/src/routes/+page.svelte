<script>
    let startDate = "";
    let endDate = "";
    let movies = [];
    let loading = false;
    let error = "";
    let page = 1;
    let totalPages = 1;
    let totalResults = 0;
    const today = new Date().toISOString().split("T")[0];

    $: if (startDate) {
        if (startDate > today) startDate = today;
        if (endDate && endDate < startDate) {
            endDate = startDate;
        }
    }

    $: if (endDate) {
        if (endDate > today) endDate = today;
        if (startDate && endDate < startDate) {
            endDate = startDate;
        }
    }

    async function searchMovies(next_page = 1, to_default = false) {
        loading = true;
        error = "";
        page = next_page;
        try {
            const params = new URLSearchParams();
            params.append("date_start", startDate);
            params.append("date_end", endDate);
            params.append("page", next_page.toString());
            if (to_default) {
                totalPages = 1;
                totalResults = 0;
            } else {
                params.append("total_results", totalResults.toString());
            }
            const res = await fetch(
                `http://localhost:3000/movies?${params.toString()}`,
            );

            if (!res.ok) throw new Error("Failed to fetch movies");

            let response = await res.json();
            movies = response.movies;
            totalResults = response.total_results;
            totalPages = Math.ceil(response.total_results / 20.0);
        } catch (e) {
            error = e.message;
            movies = [];
        } finally {
            loading = false;
        }
    }
    $: searchMovies(1, true);
</script>

<form on:submit|preventDefault={() => searchMovies(1, true)}>
    <label>
        Start Date
        <input type="date" bind:value={startDate} max={today} />
    </label>

    <label>
        End Date
        <input type="date" bind:value={endDate} min={startDate} max={today} />
        <div style:display="flex">
            <a
                href="#"
                style="padding-left: 10px;"
                on:click={() => (endDate = startDate)}
            >
                same as start date
            </a>
    
            <a
                href="#"
                style="padding-left: 10px;"
                on:click={() => (endDate = today)}
            >
                today
            </a>    
        </div>

    </label>

    <button type="submit" disabled={loading}>Search</button>
</form>

{#if loading}
    <p class="loading">Loading movies…</p>
{/if}

{#if error}
    <p class="error">{error}</p>
{/if}

{#if movies.length}
    <div class="results-grid">
        {#each movies as movie}
            <div
                class="movie-card"
                style:background-image="url({movie.poster_path})"
            >
                <div class="overlay">
                    <div class="movie-content">
                        <div class="top-row">
                            <h3>{movie.title}</h3>
                            <div class="rating-badge">
                                {movie.rating.toFixed(1)} / 10
                            </div>
                        </div>

                        <p class="date">Released: {movie.release_date}</p>
                        <p class="description">
                            Description: {movie.description}
                        </p>
                    </div>
                </div>
            </div>
        {/each}
    </div>
{:else if !loading && !error}
    <p class="empty">No movies found. Try different filters.</p>
{/if}

<div class="pagination">
    <button on:click={() => searchMovies(page - 1)} disabled={page <= 1}>
        Prev
    </button>

    <span>{page} of {totalPages}</span>

    <button
        on:click={() => {
            searchMovies(page + 1);
            document.body.scrollIntoView();
        }}
        disabled={totalPages == page}
    >
        Next
    </button>
</div>

<style>
    .pagination {
        display: flex;
        justify-content: center;
        align-items: center;
        gap: 1rem;
        margin: 2rem 0;
        font-size: 1rem;
    }
    button {
        padding: 0.5rem 1rem;
        border-radius: 6px;
        border: none;
        cursor: pointer;
        background: #0077ff;
        color: white;
        font-weight: bold;
        transition: 0.2s;
    }
    button:disabled {
        background: #ccc;
        cursor: not-allowed;
    }
    .rating-badge {
        background: #222;
        color: white;
        padding: 4px 8px;
        border-radius: 6px;
        font-weight: bold;
        display: inline-flex;
        align-items: center;
        justify-content: center;
    }

    .results-grid {
        display: grid;
        gap: 1rem;
        grid-template-columns: repeat(auto-fill, minmax(350px, 1fr));
    }

    .movie-card:hover {
        transform: translateY(-4px);
    }

    .movie-card {
        position: relative;
        border-radius: 10px;
        overflow: hidden;
        height: 500px;
        background-size: cover;
        background-position: center;
        display: flex;
    }
    .overlay {
        position: absolute;
        inset: 0;
        background: linear-gradient(
            to bottom,
            rgba(0, 0, 0, 0) 0%,
            rgba(0, 0, 0, 0.4) 40%,
            rgba(0, 0, 0, 0.85) 100%
        );
        display: flex;
        align-items: flex-end;
        padding: 1rem;
    }

    .movie-content {
        color: white;
    }

    .top-row {
        display: flex;
        justify-content: space-between;
        align-items: center;
    }

    .date {
        color: #777;
        font-size: 0.9rem;
    }

    form {
        display: flex;
        width: 100%;
        gap: 1rem;
        justify-content: center;
        padding: 1.5rem;
        background: #f7f7f7;
        border-radius: 8px;
        margin-bottom: 1.5rem;
    }

    label {
        display: flex;
        flex-direction: column;
        font-weight: 600;
        font-size: 0.9rem;
        width: 30%;
    }

    input {
        margin-top: 0.3rem;
        padding: 0.6rem;
        border: 1px solid #ccc;
        border-radius: 6px;
    }

    button {
        padding: 0.7rem 1rem;
        border: none;
        border-radius: 6px;
        background: #0077ff;
        color: white;
        font-weight: 600;
        cursor: pointer;
        transition: background 0.2s ease;
    }

    button:disabled {
        background: #a0c8ff;
        cursor: not-allowed;
    }

    button:hover:not(:disabled) {
        background: #005fcc;
    }

    .loading,
    .error,
    .empty {
        font-size: 1rem;
        margin-top: 1rem;
    }

    .error {
        color: red;
    }

    .loading {
        color: #555;
    }

    .empty {
        color: #777;
        font-style: italic;
    }
</style>
