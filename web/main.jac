import "../core/site/styles/global.css";
import "../core/site/styles/site.css";
import "../core/site/styles/brand.css";

import from core.planner_service {
    add_task,
    clear_completed,
    get_summary,
    get_tasks,
    remove_task,
    toggle_task,
}

def:pub app(children: any = None) -> JsxElement {
    return <>{children}</>;

    has title: str = "",
        notes: str = "",
        due: str = "",
        category: str = "Coursework",
        priority: str = "medium",
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
    }

    async def submit_task() {
        if title.strip() == "" {
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

    return <div style={{"minHeight":"100vh","background":"linear-gradient(135deg, #f8fafc 0%, #e2e8f0 100%)","padding":"32px","fontFamily":"Inter, system-ui, sans-serif","color":"#0f172a"}}>
        <div style={{"maxWidth":"1200px","margin":"0 auto"}}>
            <header style={{"display":"flex","justifyContent":"space-between","alignItems":"center","marginBottom":"24px"}}>
                <div>
                    <div style={{"fontSize":"12px","letterSpacing":"0.18em","fontWeight":"700","textTransform":"uppercase","color":"#475569"}}>Personal planner</div>
                    <h1 style={{"margin":"6px 0 0 0","fontSize":"38px","lineHeight":"1.1"}}>PlanPilot</h1>
                </div>
                <button style={{"border":"none","background":"#0f172a","color":"#f8fafc","borderRadius":"999px","padding":"12px 18px","fontWeight":"700","cursor":"pointer"}} onClick={lambda { prune_done(); }}>
                    Clear completed
                </button>
            </header>

            <div style={{"display":"grid","gridTemplateColumns":"400px minmax(0, 1fr)","gap":"24px"}}>
                <section style={{"background":"rgba(255,255,255,0.9)","border":"1px solid rgba(148,163,184,0.35)","boxShadow":"0 24px 45px rgba(15,23,42,0.08)","borderRadius":"28px","padding":"24px"}}>
                    <h2 style={{"marginTop":"0","marginBottom":"18px","fontSize":"24px"}}>New task</h2>

                    <div style={{"display":"grid","gap":"14px"}}>
                        <input
                            type="text"
                            placeholder="Task title"
                            value={title}
                            onChange={lambda (e: ChangeEvent) { title = e.target.value; }}
                            style={{"padding":"12px 14px","borderRadius":"12px","border":"1px solid #cbd5e1","fontSize":"15px","background":"#ffffff"}}
                        />
                        <textarea
                            placeholder="Notes"
                            value={notes}
                            onChange={lambda (e: ChangeEvent) { notes = e.target.value; }}
                            rows={4}
                            style={{"padding":"12px 14px","borderRadius":"12px","border":"1px solid #cbd5e1","fontSize":"15px","background":"#ffffff","resize":"vertical"}}
                        ></textarea>
                        <div style={{"display":"grid","gridTemplateColumns":"1fr 1fr","gap":"14px"}}>
                            <input
                                type="date"
                                value={due}
                                onChange={lambda (e: ChangeEvent) { due = e.target.value; }}
                                style={{"padding":"12px 14px","borderRadius":"12px","border":"1px solid #cbd5e1","fontSize":"15px","background":"#ffffff"}}
                            />
                            <select
                                value={category}
                                onChange={lambda (e: ChangeEvent) { category = e.target.value; }}
                                style={{"padding":"12px 14px","borderRadius":"12px","border":"1px solid #cbd5e1","fontSize":"15px","background":"#ffffff"}}
                            >
                                <option value="Coursework">Coursework</option>
                                <option value="Wellness">Wellness</option>
                                <option value="Personal">Personal</option>
                                <option value="Errands">Errands</option>
                            </select>
                        </div>
                        <select
                            value={priority}
                            onChange={lambda (e: ChangeEvent) { priority = e.target.value; }}
                            style={{"padding":"12px 14px","borderRadius":"12px","border":"1px solid #cbd5e1","fontSize":"15px","background":"#ffffff"}}
                        >
                            <option value="high">High priority</option>
                            <option value="medium">Medium priority</option>
                            <option value="low">Low priority</option>
                        </select>
                        <button style={{"padding":"14px 18px","borderRadius":"12px","border":"none","background":"linear-gradient(135deg, #0f172a 0%, #334155 100%)","color":"#f8fafc","fontWeight":"700","cursor":"pointer"}} onClick={lambda { submit_task(); }}>
                            Add to plan
                        </button>
                    </div>
                </section>

                <section style={{"display":"grid","gap":"18px"}}>
                    <div style={{"display":"grid","gridTemplateColumns":"repeat(4, minmax(0,1fr))","gap":"16px"}}>
                        <div style={{"background":"#0f172a","borderRadius":"20px","padding":"18px","color":"#f8fafc"}}>
                            <div style={{"fontSize":"12px","textTransform":"uppercase","letterSpacing":"0.12em","opacity":"0.8"}}>Total</div>
                            <div style={{"fontSize":"32px","fontWeight":"800","marginTop":"10px"}}>{str(summary["total"])}</div>
                        </div>
                        <div style={{"background":"#f8fafc","border":"1px solid rgba(148,163,184,0.4)","borderRadius":"20px","padding":"18px"}}>
                            <div style={{"fontSize":"12px","textTransform":"uppercase","letterSpacing":"0.12em","color":"#475569"}}>Pending</div>
                            <div style={{"fontSize":"32px","fontWeight":"800","marginTop":"10px"}}>{str(summary["pending"])}</div>
                        </div>
                        <div style={{"background":"#fef2f2","border":"1px solid rgba(248,113,113,0.35)","borderRadius":"20px","padding":"18px"}}>
                            <div style={{"fontSize":"12px","textTransform":"uppercase","letterSpacing":"0.12em","color":"#b91c1c"}}>High</div>
                            <div style={{"fontSize":"32px","fontWeight":"800","marginTop":"10px"}}>{str(summary["high"])}</div>
                        </div>
                        <div style={{"background":"#ecfdf5","border":"1px solid rgba(16,185,129,0.35)","borderRadius":"20px","padding":"18px"}}>
                            <div style={{"fontSize":"12px","textTransform":"uppercase","letterSpacing":"0.12em","color":"#065f46"}}>Done</div>
                            <div style={{"fontSize":"32px","fontWeight":"800","marginTop":"10px"}}>{str(summary["done"])}</div>
                        </div>
                    </div>

                    <div style={{"background":"rgba(255,255,255,0.9)","border":"1px solid rgba(148,163,184,0.35)","boxShadow":"0 24px 45px rgba(15,23,42,0.08)","borderRadius":"28px","padding":"24px"}}>
                        <div style={{"display":"flex","justifyContent":"space-between","alignItems":"center","marginBottom":"18px"}}>
                            <h2 style={{"margin":"0","fontSize":"24px"}}>Today’s plan</h2>
                            <span style={{"fontSize":"13px","color":"#64748b"}}>{str(len(tasks))} items</span>
                        </div>

                        {if len(tasks) == 0 {
                            <div style={{"padding":"24px 12px","textAlign":"center","color":"#64748b","border":"1px dashed #cbd5e1","borderRadius":"18px"}}>
                                No tasks yet — add your first plan item to get started.
                            </div>
                        } else {
                            <div style={{"display":"grid","gap":"12px"}}>
                                {for task in tasks {
                                    <div key={task["id"] as str} style={{"display":"flex","alignItems":"center","justifyContent":"space-between","gap":"12px","padding":"14px 16px","borderRadius":"16px","border":"1px solid #e2e8f0","background":"#f8fafc"}}>
                                        <div style={{"flex":"1","minWidth":"0"}}>
                                            <div style={{"display":"flex","alignItems":"center","gap":"8px","flexWrap":"wrap"}}>
                                                <input type="checkbox" checked={task["done"] as bool} onChange={lambda { mark_done(task["id"] as str); }} style={{"width":"18px","height":"18px"}} />
                                                <span style={{"fontSize":"18px","fontWeight":"700", "textDecoration": ("line-through" if task["done"] else "none")}}>{task["title"] as str}</span>
                                            </div>
                                            {if task["notes"] != "" {
                                                <div style={{"marginTop":"6px","fontSize":"14px","color":"#475569"}}>{task["notes"] as str}</div>
                                            }}
                                            <div style={{"marginTop":"8px","display":"flex","gap":"8px","flexWrap":"wrap"}}>
                                                <span style={{"padding":"4px 8px","borderRadius":"999px","background":"#e2e8f0","fontSize":"11px","fontWeight":"700","color":"#334155"}}>{task["category"] as str}</span>
                                                <span style={{"padding":"4px 8px","borderRadius":"999px","background":"#dbeafe","fontSize":"11px","fontWeight":"700","color":"#1d4ed8"}}>{(task["priority"] as str).upper()}</span>
                                                {if task["due"] != "" {
                                                    <span style={{"padding":"4px 8px","borderRadius":"999px","background":"#ecfeff","fontSize":"11px","fontWeight":"700","color":"#0f766e"}}>{task["due"] as str}</span>
                                                }}
                                            </div>
                                        </div>
                                        <button style={{"border":"1px solid #cbd5e1","background":"#ffffff","color":"#0f172a","padding":"8px 10px","borderRadius":"10px","cursor":"pointer"}} onClick={lambda { drop_task(task["id"] as str); }}>
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
