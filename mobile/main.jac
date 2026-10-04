import from "@jac/mobui" { View, Text, Pressable, TextInput }

import from core.planner_service {
    add_task,
    clear_completed,
    complete_task,
    get_active_tasks,
    get_next_task,
    get_summary,
    remove_task,
}

def:pub app -> JsxElement {
    has task_title: str = "",
        error_message: str = "",
        tasks: list[dict[str, any]] = [],
        next_task: dict[str, any] | None = None,
        summary: dict[str, any] = {"total": 0, "done": 0, "pending": 0, "high": 0};

    async can with entry {
        await refresh();
    }

    async def refresh() {
        tasks = await get_active_tasks();
        summary = await get_summary();
        next_task = await get_next_task();
    }

    async def quick_add() {
        if task_title.strip() == "" {
            error_message = "Title is required.";
            return;
        }
        await add_task(title=task_title, category="Quick", priority="medium");
        task_title = "";
        error_message = "";
        await refresh();
    }

    async def complete(task_id: str) {
        await complete_task(task_id);
        await refresh();
    }

    async def remove(task_id: str) {
        await remove_task(task_id);
        await refresh();
    }

    async def clear_done() {
        await clear_completed();
        await refresh();
    }

    return <View style={{"maxWidth": 420, "marginLeft": "auto", "marginRight": "auto", "paddingTop": 24, "paddingBottom": 40, "paddingLeft": 16, "paddingRight": 16, "backgroundColor": "#f8fafc", "minHeight": "100%"}}>
        <View style={{"display": "flex", "flexDirection": "row", "alignItems": "center", "justifyContent": "space-between", "marginBottom": 18}}>
            <View>
                <Text style={{"fontSize": 11, "letterSpacing": 1.8, "textTransform": "uppercase", "color": "#64748b", "fontWeight": "700"}}>Quick view</Text>
                <Text style={{"marginTop": 6, "fontSize": 30, "fontWeight": "800", "color": "#0f172a"}}>PlanPilot</Text>
            </View>
            <Pressable onPress={lambda { clear_done(); }} style={{"backgroundColor": "#0f172a", "paddingTop": 10, "paddingBottom": 10, "paddingLeft": 14, "paddingRight": 14, "borderRadius": 999}}>
                <Text style={{"color": "#f8fafc", "fontWeight": "700"}}>Clear</Text>
            </Pressable>
        </View>

        <View style={{"backgroundColor": "#0f172a", "padding": 16, "borderRadius": 18, "marginBottom": 18}}>
            <Text style={{"fontSize": 12, "textTransform": "uppercase", "letterSpacing": 1.8, "opacity": 0.8, "color": "#f8fafc"}}>Progress</Text>
            <View style={{"display": "flex", "flexDirection": "row", "justifyContent": "space-between", "marginTop": 12, "gap": 10}}>
                <Text style={{"color": "#f8fafc", "fontWeight": "700"}}>{str(summary["pending"])} active</Text>
                <Text style={{"color": "#f8fafc", "fontWeight": "700"}}>{str(summary["done"])} done</Text>
                <Text style={{"color": "#f8fafc", "fontWeight": "700"}}>{str(summary["high"])} high</Text>
            </View>
        </View>

        {if next_task is not None {
            <View style={{"marginBottom": 18, "padding": 16, "borderRadius": 18, "borderWidth": 2, "borderColor": "#27323a", "backgroundColor": "#fff6d9"}}>
                <Text style={{"fontSize": 11, "letterSpacing": 1.8, "textTransform": "uppercase", "color": "#8a5f10", "fontWeight": "700"}}>Recommended next</Text>
                <Text style={{"marginTop": 8, "fontSize": 20, "fontWeight": "800", "color": "#0f172a"}}>{next_task["title"] as str}</Text>
                <Text style={{"marginTop": 6, "fontSize": 13, "color": "#475569", "fontWeight": "700"}}>{(next_task["priority"] as str).capitalize()} priority{(" • Due " + (next_task["due"] as str)) if next_task["due"] != "" else " • No due date"}</Text>
            </View>
        } else {
            <View style={{"marginBottom": 18, "padding": 16, "borderRadius": 18, "borderWidth": 1, "borderColor": "#cbd5e1", "borderStyle": "dashed", "backgroundColor": "rgba(255,255,255,0.7)"}}>
                <Text style={{"textAlign": "center", "color": "#64748b", "fontWeight": "700"}}>All active tasks are complete.</Text>
            </View>
        }}

        <View style={{"display": "flex", "flexDirection": "row", "gap": 10, "marginBottom": 12}}>
            <TextInput
                value={task_title}
                onChangeText={lambda (value: str) { task_title = value; error_message = ""; }}
                placeholder="Add a quick task"
                style={{"flex": 1, "paddingTop": 14, "paddingBottom": 14, "paddingLeft": 12, "paddingRight": 12, "borderRadius": 12, "borderWidth": 1, "borderColor": "#cbd5e1", "backgroundColor": "#ffffff", "fontSize": 15}}
            />
            <Pressable onPress={lambda { quick_add(); }} style={{"paddingTop": 14, "paddingBottom": 14, "paddingLeft": 16, "paddingRight": 16, "borderRadius": 12, "backgroundColor": "#2563eb"}}>
                <Text style={{"color": "#ffffff", "fontWeight": "700"}}>Add</Text>
            </Pressable>
        </View>

        {if error_message != "" {
            <View style={{"marginBottom": 18, "padding": 12, "borderRadius": 14, "borderWidth": 1, "borderColor": "rgba(220,38,38,0.22)", "backgroundColor": "rgba(254,242,242,0.92)"}}>
                <Text style={{"color": "#b91c1c", "fontWeight": "700", "fontSize": 13}}>{error_message}</Text>
            </View>
        }}

        <View style={{"display": "flex", "gap": 12}}>
            {if len(tasks) == 0 {
                <View style={{"padding": 20, "backgroundColor": "rgba(255,255,255,0.85)", "borderRadius": 18, "borderWidth": 1, "borderColor": "#cbd5e1", "borderStyle": "dashed"}}>
                    <Text style={{"textAlign": "center", "color": "#64748b"}}>No active tasks yet.</Text>
                </View>
            } else {
                for task in tasks {
                    <View key={task["id"] as str} style={{"backgroundColor": "rgba(255,255,255,0.9)", "borderWidth": 1, "borderColor": "rgba(148,163,184,0.35)", "borderRadius": 18, "padding": 14}}>
                        <View style={{"display": "flex", "flexDirection": "row", "alignItems": "center", "justifyContent": "space-between", "gap": 8}}>
                            <View style={{"display": "flex", "flexDirection": "row", "alignItems": "center", "gap": 8, "flex": 1}}>
                                <Pressable onPress={lambda { complete(task["id"] as str); }} style={{"padding": 4}}>
                                    <Text>{"✓"}</Text>
                                </Pressable>
                                <Text style={{"fontWeight": "700", "color": "#0f172a"}}>{task["title"] as str}</Text>
                            </View>
                            <Pressable onPress={lambda { remove(task["id"] as str); }} style={{"padding": 4}}>
                                <Text style={{"color": "#dc2626", "fontWeight": "700"}}>X</Text>
                            </Pressable>
                        </View>
                        {if task["due"] != "" {
                            <Text style={{"marginTop": 8, "fontSize": 12, "color": "#475569"}}>Due {task["due"] as str}</Text>
                        }}
                        <Text style={{"marginTop": 6, "fontSize": 12, "color": "#64748b", "fontWeight": "700"}}>{(task["priority"] as str).capitalize()} priority</Text>
                    </View>
                }
            }}
        </View>
    </View>;
}
