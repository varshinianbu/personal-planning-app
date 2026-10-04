import from core.planner_service {
    add_task,
    clear_completed,
    get_next_task,
    get_summary,
    get_tasks,
    remove_task,
    toggle_task,
}

def:pub page -> JsxPage {
    has title: str = "",
        notes: str = "",
        due: str = "",
        category: str = "Coursework",
        priority: str = "medium",
        next_task: dict[str, any] | None = None,
        error_message: str = "",
        tasks: list[dict[str, any]] = [],
        summary: dict[str, any] = {
            "total": 0,
            "done": 0,
            "pending": 0,
            "high": 0,
            "medium": 0,
            "low": 0,
        };

    async can with entry {
        await refresh();
    }

    async def refresh() {
        tasks = await get_tasks();
        summary = await get_summary();
        next_task = await get_next_task();
    }

    async def submit_task() {
        if title.strip() == "" {
            error_message = "Title is required.";
            return;
        }
        await add_task(
            title=title,
            notes=notes,
            due=due,
            category=category,
            priority=priority,
        );
        title = "";
        notes = "";
        due = "";
        category = "Coursework";
        priority = "medium";
        error_message = "";
        await refresh();
    }

    async def mark_done(task_id: str) {
        await toggle_task(task_id);
        await refresh();
    }

    async def drop_task(task_id: str) {
        await remove_task(task_id);
        await refresh();
    }

    async def prune_done() {
        await clear_completed();
        await refresh();
    }

    return <div style={{"minHeight": "100vh", "background": "linear-gradient(180deg, #b8d3e7 0%, #c7deef 26%, #d8e9f5 100%)", "padding": "20px 18px 44px", "fontFamily": "'Comic Sans MS', 'Trebuchet MS', system-ui, sans-serif", "color": "#2b2b2b"}}>
        <div style={{"maxWidth": "1260px", "margin": "0 auto"}}>
            <header style={{"display": "flex", "alignItems": "center", "justifyContent": "space-between", "gap": "16px", "marginBottom": "18px", "flexWrap": "wrap"}}>
                <div style={{"display": "flex", "alignItems": "center", "gap": "14px", "flexWrap": "wrap"}}>
                    <div style={{"width": "54px", "height": "54px", "borderRadius": "18px", "background": "rgba(255,255,255,0.88)", "border": "2px solid rgba(45,86,116,0.18)", "boxShadow": "0 10px 24px rgba(37,71,96,0.08)", "display": "grid", "placeItems": "center", "fontSize": "24px"}}>✦</div>
                    <div>
                        <div style={{"fontSize": "11px", "letterSpacing": "0.22em", "fontWeight": "700", "textTransform": "uppercase", "color": "#4f6e86", "marginBottom": "6px"}}>soft planning board</div>
                        <h1 style={{"margin": "0", "fontSize": "44px", "lineHeight": "1", "letterSpacing": "-0.05em", "color": "#153042"}}>PlanPilot</h1>
                    </div>
                </div>

                <div style={{"display": "flex", "alignItems": "center", "gap": "10px", "flexWrap": "wrap"}}>
                    <div style={{"padding": "10px 14px", "borderRadius": "999px", "background": "rgba(255,255,255,0.78)", "border": "1.5px solid rgba(45,86,116,0.18)", "fontSize": "12px", "fontWeight": "700", "color": "#406078", "boxShadow": "0 8px 18px rgba(37,71,96,0.06)"}}>
                        {str(summary["total"])} tasks in orbit
                    </div>
                    <button style={{"border": "1.5px solid #173246", "background": "#173246", "color": "#ffffff", "borderRadius": "999px", "padding": "12px 18px", "fontWeight": "700", "cursor": "pointer", "boxShadow": "0 14px 24px rgba(23,50,70,0.18)"}} onClick={lambda { prune_done(); }}>
                        Clear completed
                    </button>
                </div>
            </header>

            <div style={{"display": "grid", "gridTemplateColumns": "minmax(320px, 390px) minmax(0, 1fr)", "gap": "22px", "alignItems": "start"}}>
                <section style={{"position": "relative", "background": "rgba(255,248,238,0.96)", "border": "2px solid rgba(51,77,96,0.16)", "boxShadow": "0 20px 40px rgba(38,72,95,0.11)", "borderRadius": "34px", "padding": "22px 20px 20px", "overflow": "visible"}}>
                    <div style={{"display": "flex", "justifyContent": "space-between", "alignItems": "center", "marginBottom": "14px", "gap": "10px", "flexWrap": "wrap"}}>
                        <h2 style={{"margin": "0", "fontSize": "23px", "fontWeight": "800", "color": "#1e3443"}}>New note</h2>
                        <span style={{"padding": "6px 12px", "borderRadius": "999px", "background": "#f4efe6", "border": "1px solid rgba(51,77,96,0.12)", "color": "#6a5646", "fontSize": "11px", "fontWeight": "700", "letterSpacing": "0.12em", "textTransform": "uppercase"}}>hand-drafted</span>
                    </div>

                    <div style={{"display": "grid", "gap": "12px"}}>
                        <div>
                            <label style={{"display": "block", "marginBottom": "7px", "fontSize": "11px", "fontWeight": "700", "color": "#6c7f8b", "letterSpacing": "0.18em", "textTransform": "uppercase"}}>Title</label>
                            <input
                                type="text"
                                placeholder="title"
                                value={title}
                                onChange={lambda (e: ChangeEvent) { title = e.target.value; error_message = ""; }}
                                style={{"width": "100%", "padding": "14px 16px", "borderRadius": "22px", "border": "2px solid #262626", "fontSize": "18px", "background": "#fffef9", "boxSizing": "border-box", "boxShadow": "inset 0 1px 0 rgba(255,255,255,0.72)"}}
                            />
                        </div>

                        <div style={{"display": "grid", "gridTemplateColumns": "1fr 1fr", "gap": "12px"}}>
                            <div>
                                <label style={{"display": "block", "marginBottom": "7px", "fontSize": "11px", "fontWeight": "700", "color": "#6c7f8b", "letterSpacing": "0.18em", "textTransform": "uppercase"}}>Date</label>
                                <input
                                    type="date"
                                    value={due}
                                    onChange={lambda (e: ChangeEvent) { due = e.target.value; error_message = ""; }}
                                    style={{"width": "100%", "padding": "13px 14px", "borderRadius": "22px", "border": "2px solid #262626", "fontSize": "15px", "background": "#fffef9", "boxSizing": "border-box"}}
                                />
                            </div>
                            <div>
                                <label style={{"display": "block", "marginBottom": "7px", "fontSize": "11px", "fontWeight": "700", "color": "#6c7f8b", "letterSpacing": "0.18em", "textTransform": "uppercase"}}>Category</label>
                                <select
                                    value={category}
                                    onChange={lambda (e: ChangeEvent) { category = e.target.value; error_message = ""; }}
                                    style={{"width": "100%", "padding": "13px 14px", "borderRadius": "22px", "border": "2px solid #262626", "fontSize": "15px", "background": "#fffef9", "boxSizing": "border-box"}}
                                >
                                    <option value="Coursework">Coursework</option>
                                    <option value="Wellness">Wellness</option>
                                    <option value="Personal">Personal</option>
                                    <option value="Errands">Errands</option>
                                </select>
                            </div>
                        </div>

                        <div>
                            <label style={{"display": "block", "marginBottom": "7px", "fontSize": "11px", "fontWeight": "700", "color": "#6c7f8b", "letterSpacing": "0.18em", "textTransform": "uppercase"}}>Notes</label>
                            <textarea
                                placeholder="sketch the thought here..."
                                value={notes}
                                onChange={lambda (e: ChangeEvent) { notes = e.target.value; error_message = ""; }}
                                rows={6}
                                style={{"width": "100%", "padding": "15px 16px", "borderRadius": "26px", "border": "2px solid #262626", "fontSize": "15px", "background": "radial-gradient(circle at 1px 1px, rgba(38,38,38,0.09) 1px, transparent 0)", "backgroundSize": "12px 12px", "resize": "vertical", "boxSizing": "border-box", "lineHeight": "1.55"}}
                            ></textarea>
                        </div>

                        <div>
                            <label style={{"display": "block", "marginBottom": "7px", "fontSize": "11px", "fontWeight": "700", "color": "#6c7f8b", "letterSpacing": "0.18em", "textTransform": "uppercase"}}>Priority</label>
                            <select
                                value={priority}
                                onChange={lambda (e: ChangeEvent) { priority = e.target.value; error_message = ""; }}
                                style={{"width": "100%", "padding": "13px 14px", "borderRadius": "22px", "border": "2px solid #262626", "fontSize": "15px", "background": "#fffef9", "boxSizing": "border-box"}}
                            >
                                <option value="high">High priority</option>
                                <option value="medium">Medium priority</option>
                                <option value="low">Low priority</option>
                            </select>
                        </div>

                        <button style={{"marginTop": "6px", "padding": "15px 18px", "borderRadius": "24px", "border": "2px solid #262626", "background": "linear-gradient(135deg, #fef3c7 0%, #fff8e7 100%)", "color": "#1f2937", "fontWeight": "800", "cursor": "pointer", "boxShadow": "0 12px 20px rgba(38,38,38,0.12)", "fontSize": "16px"}} onClick={lambda { submit_task(); }}>
                            Add to plan
                        </button>
                        {if error_message != "" {
                            <div style={{"padding": "12px 14px", "borderRadius": "18px", "border": "1px solid rgba(220,38,38,0.22)", "background": "rgba(254,242,242,0.92)", "color": "#b91c1c", "fontSize": "13px", "fontWeight": "700"}}>
                                {error_message}
                            </div>
                        }}
                    </div>
                </section>

                <section style={{"display": "grid", "gap": "18px"}}>
                    <div style={{"display": "grid", "gridTemplateColumns": "repeat(4, minmax(0,1fr))", "gap": "12px"}}>
                        <div style={{"background": "#fffaf0", "border": "2px solid rgba(38,38,38,0.13)", "borderRadius": "26px", "padding": "16px", "boxShadow": "0 10px 18px rgba(38,72,95,0.08)"}}>
                            <div style={{"fontSize": "10px", "textTransform": "uppercase", "letterSpacing": "0.18em", "color": "#5f7482"}}>Total</div>
                            <div style={{"fontSize": "34px", "fontWeight": "800", "marginTop": "10px", "color": "#243a49"}}>{str(summary["total"])}</div>
                        </div>
                        <div style={{"background": "#f7fbff", "border": "2px solid rgba(38,38,38,0.13)", "borderRadius": "26px", "padding": "16px", "boxShadow": "0 10px 18px rgba(38,72,95,0.08)"}}>
                            <div style={{"fontSize": "10px", "textTransform": "uppercase", "letterSpacing": "0.18em", "color": "#5f7482"}}>Pending</div>
                            <div style={{"fontSize": "34px", "fontWeight": "800", "marginTop": "10px", "color": "#243a49"}}>{str(summary["pending"])}</div>
                        </div>
                        <div style={{"background": "#fff3f4", "border": "2px solid rgba(38,38,38,0.13)", "borderRadius": "26px", "padding": "16px", "boxShadow": "0 10px 18px rgba(38,72,95,0.08)"}}>
                            <div style={{"fontSize": "10px", "textTransform": "uppercase", "letterSpacing": "0.18em", "color": "#9c4d5a"}}>High</div>
                            <div style={{"fontSize": "34px", "fontWeight": "800", "marginTop": "10px", "color": "#9c3447"}}>{str(summary["high"])}</div>
                        </div>
                        <div style={{"background": "#effaf4", "border": "2px solid rgba(38,38,38,0.13)", "borderRadius": "26px", "padding": "16px", "boxShadow": "0 10px 18px rgba(38,72,95,0.08)"}}>
                            <div style={{"fontSize": "10px", "textTransform": "uppercase", "letterSpacing": "0.18em", "color": "#4e7c61"}}>Done</div>
                            <div style={{"fontSize": "34px", "fontWeight": "800", "marginTop": "10px", "color": "#31714d"}}>{str(summary["done"])}</div>
                        </div>
                    </div>

                    <div style={{"background": "rgba(255,255,255,0.8)", "border": "2px solid rgba(38,38,38,0.13)", "boxShadow": "0 18px 36px rgba(38,72,95,0.10)", "borderRadius": "34px", "padding": "20px"}}>
                        <div style={{"display": "flex", "justifyContent": "space-between", "alignItems": "center", "marginBottom": "14px", "gap": "12px", "flexWrap": "wrap"}}>
                            <div>
                                <div style={{"fontSize": "10px", "letterSpacing": "0.2em", "textTransform": "uppercase", "color": "#6c7f8b", "fontWeight": "700"}}>Inbox board</div>
                                <h2 style={{"margin": "6px 0 0 0", "fontSize": "24px", "fontWeight": "800", "color": "#1f3645"}}>Today’s plan</h2>
                            </div>
                            <span style={{"fontSize": "12px", "color": "#5f7482", "padding": "8px 12px", "borderRadius": "999px", "background": "#f7fbff", "border": "1.5px solid rgba(38,38,38,0.12)", "fontWeight": "700"}}>{str(summary["pending"])} active</span>
                        </div>

                        {if next_task is not None {
                            <div style={{"marginBottom": "14px", "padding": "18px", "borderRadius": "26px", "border": "2px solid #27323a", "background": "linear-gradient(135deg, rgba(254,243,199,0.82) 0%, rgba(255,250,235,0.96) 100%)", "boxShadow": "4px 4px 0 rgba(38,38,38,0.08)"}}>
                                <div style={{"fontSize": "10px", "letterSpacing": "0.18em", "textTransform": "uppercase", "color": "#8a5f10", "fontWeight": "700"}}>Recommended next</div>
                                <div style={{"marginTop": "8px", "fontSize": "21px", "fontWeight": "800", "color": "#1f3645"}}>{str(next_task["title"])}</div>
                                <div style={{"marginTop": "6px", "display": "flex", "gap": "8px", "flexWrap": "wrap"}}>
                                    <span style={{"padding": "5px 10px", "borderRadius": "999px", "background": "rgba(231,241,251,0.95)", "fontSize": "11px", "fontWeight": "700", "color": "#2a5d86", "border": "1px solid rgba(38,38,38,0.08)"}}>{str(next_task["priority"]).capitalize()} priority</span>
                                    {if str(next_task["due"]) != "" {
                                        <span style={{"padding": "5px 10px", "borderRadius": "999px", "background": "rgba(239,250,244,0.95)", "fontSize": "11px", "fontWeight": "700", "color": "#2f7850", "border": "1px solid rgba(38,38,38,0.08)"}}>Due {next_task["due"] as str}</span>
                                    } else {
                                        <span style={{"padding": "5px 10px", "borderRadius": "999px", "background": "rgba(239,250,244,0.95)", "fontSize": "11px", "fontWeight": "700", "color": "#2f7850", "border": "1px solid rgba(38,38,38,0.08)"}}>No due date</span>
                                    }}
                                </div>
                            </div>
                        } elif len(tasks) > 0 {
                            <div style={{"marginBottom": "14px", "padding": "18px", "borderRadius": "26px", "border": "2px dashed rgba(38,38,38,0.18)", "background": "rgba(248,250,252,0.72)", "color": "#51616d", "fontSize": "15px", "fontWeight": "700"}}>
                                All active tasks are complete. Completed cards are still shown below.
                            </div>
                        }}

                        {if len(tasks) == 0 {
                            <div style={{"display": "grid", "gap": "16px", "padding": "18px 6px 6px"}}>
                                <div style={{"display": "grid", "gridTemplateColumns": "1fr 92px", "gap": "14px", "alignItems": "center"}}>
                                    <div style={{"height": "120px", "borderRadius": "28px", "background": "#fffdf6", "border": "2px solid #27323a", "boxShadow": "6px 6px 0 rgba(38,38,38,0.08)", "position": "relative"}}>
                                        <div style={{"position": "absolute", "inset": "12px", "borderRadius": "22px", "background": "radial-gradient(circle at 1px 1px, rgba(38,38,38,0.08) 1px, transparent 0)", "backgroundSize": "12px 12px", "opacity": "0.6"}}></div>
                                    </div>
                                    <div style={{"width": "42px", "height": "42px", "borderRadius": "999px", "border": "2px dashed rgba(38,38,38,0.18)", "justifySelf": "center"}}></div>
                                </div>
                                <div style={{"padding": "22px", "textAlign": "center", "color": "#51616d", "border": "2px dashed rgba(38,38,38,0.18)", "borderRadius": "24px", "background": "rgba(248,250,252,0.72)", "fontSize": "15px"}}>
                                    No tasks yet — add a first note and it will appear here as a paper card.
                                </div>
                            </div>
                        } else {
                            <div style={{"display": "grid", "gap": "14px"}}>
                                {for task in tasks {
                                    <div key={task["id"] as str} style={{"display": "grid", "gridTemplateColumns": "1fr auto", "gap": "14px", "alignItems": "start", "padding": "16px 16px 15px", "borderRadius": "30px", "border": "2px solid #27323a", "background": "#fffdf8", "boxShadow": "7px 7px 0 rgba(38,38,38,0.09)"}}>
                                        <div style={{"minWidth": "0"}}>
                                            <div style={{"display": "flex", "alignItems": "center", "gap": "10px", "flexWrap": "wrap"}}>
                                                <input type="checkbox" checked={task["done"] as bool} onChange={lambda { mark_done(task["id"] as str); }} style={{"width": "18px", "height": "18px", "accentColor": "#173246"}} />
                                                <span style={{"fontSize": "18px", "fontWeight": "800", "color": "#173246", "textDecoration": ("line-through" if task["done"] else "none")}}>{task["title"] as str}</span>
                                            </div>
                                            {if task["notes"] != "" {
                                                <div style={{"marginTop": "8px", "fontSize": "14px", "color": "#51616d", "lineHeight": "1.55", "paddingLeft": "28px"}}>{task["notes"] as str}</div>
                                            }}
                                            <div style={{"marginTop": "12px", "display": "flex", "gap": "8px", "flexWrap": "wrap", "paddingLeft": "28px"}}>
                                                <span style={{"padding": "5px 10px", "borderRadius": "999px", "background": "#e7f1fb", "fontSize": "11px", "fontWeight": "700", "color": "#2a5d86", "border": "1px solid rgba(38,38,38,0.08)"}}>{task["category"] as str}</span>
                                                <span style={{"padding": "5px 10px", "borderRadius": "999px", "background": "#f3ecff", "fontSize": "11px", "fontWeight": "700", "color": "#6348a6", "border": "1px solid rgba(38,38,38,0.08)"}}>{(task["priority"] as str).upper()}</span>
                                                {if task["due"] != "" {
                                                    <span style={{"padding": "5px 10px", "borderRadius": "999px", "background": "#eefaf4", "fontSize": "11px", "fontWeight": "700", "color": "#2f7850", "border": "1px solid rgba(38,38,38,0.08)"}}>{task["due"] as str}</span>
                                                }}
                                            </div>
                                        </div>
                                        <button style={{"border": "2px solid #27323a", "background": "#ffffff", "color": "#27323a", "padding": "9px 13px", "borderRadius": "18px", "cursor": "pointer", "fontWeight": "800", "boxShadow": "3px 3px 0 rgba(38,38,38,0.08)"}} onClick={lambda { drop_task(task["id"] as str); }}>
                                            Delete
                                        </button>
                                    </div>
                                }}
                            </div>
                        }}
                    </div>
                </section>
            </div>
        </div>
    </div>;
}
