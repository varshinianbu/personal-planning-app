import from "@jac/mobui" { View, Text, Pressable, TextInput }

import from core.planner_service {
    add_task,
    clear_completed,
    get_summary,
    get_tasks,
    remove_task,
    toggle_task,
}

def:pub app -> JsxElement {
    has taskTitle: str = "",
        tasks: list[dict[str, any]] = [],
        summary: dict[str, any] = {"total": 0, "done": 0, "pending": 0};

    async can with entry {
        await refresh();
    }

    async def refresh() {
        tasks = await get_tasks();
        summary = await get_summary();
    }

    async def quick_add() {
        if taskTitle.strip() == "" {
            return;
        }
        await add_task(title=taskTitle, category="Quick", priority="medium");
        taskTitle = "";
        await refresh();
    }

    async def complete(task_id: str) {
        await toggle_task(task_id);
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

    <View style={{"maxWidth": 420, "marginLeft": "auto", "marginRight": "auto", "paddingTop": 24, "paddingBottom": 40, "paddingLeft": 16, "paddingRight": 16, "backgroundColor": "#f8fafc", "minHeight": "100%"}}>
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
            <View style={{"display": "flex", "flexDirection": "row", "justifyContent": "space-between", "marginTop": 12}}>
                <Text style={{"color": "#f8fafc", "fontWeight": "700"}}>{str(summary["pending"])} left</Text>
                <Text style={{"color": "#f8fafc", "fontWeight": "700"}}>{str(summary["done"])} done</Text>
            </View>
        </View>

        <View style={{"display": "flex", "flexDirection": "row", "gap": 10, "marginBottom": 18}}>
            <TextInput
                value={taskTitle}
                onChangeText={lambda (value: str) { taskTitle = value; }}
                placeholder="Add a quick task"
                style={{"flex": 1, "paddingTop": 14, "paddingBottom": 14, "paddingLeft": 12, "paddingRight": 12, "borderRadius": 12, "borderWidth": 1, "borderColor": "#cbd5e1", "backgroundColor": "#ffffff", "fontSize": 15}}
            />
            <Pressable onPress={lambda { quick_add(); }} style={{"paddingTop": 14, "paddingBottom": 14, "paddingLeft": 16, "paddingRight": 16, "borderRadius": 12, "backgroundColor": "#2563eb"}}>
                <Text style={{"color": "#ffffff", "fontWeight": "700"}}>Add</Text>
            </Pressable>
        </View>

        <View style={{"display": "flex", "gap": 12}}>
            if len(tasks) == 0 {
                <View style={{"padding": 20, "backgroundColor": "rgba(255,255,255,0.85)", "borderRadius": 18, "borderWidth": 1, "borderColor": "#cbd5e1", "borderStyle": "dashed"}}>
                    <Text style={{"textAlign": "center", "color": "#64748b"}}>No tasks yet.</Text>
                </View>
            } else {
                for task in tasks {
                    <View key={task["id"] as str} style={{"backgroundColor": "rgba(255,255,255,0.9)", "borderWidth": 1, "borderColor": "rgba(148,163,184,0.35)", "borderRadius": 18, "padding": 14}}>
                        <View style={{"display": "flex", "flexDirection": "row", "alignItems": "center", "justifyContent": "space-between", "gap": 8}}>
                            <View style={{"display": "flex", "flexDirection": "row", "alignItems": "center", "gap": 8, "flex": 1}}>
                                <Pressable onPress={lambda { complete(task["id"] as str); }} style={{"padding": 4}}>
                                    <Text>{"✓" if task["done"] else "○"}</Text>
                                </Pressable>
                                <Text style={{"fontWeight": "700", "textDecorationLine": ("line-through" if task["done"] else "none"), "color": "#0f172a"}}>{task["title"] as str}</Text>
                            </View>
                            <Pressable onPress={lambda { remove(task["id"] as str); }} style={{"padding": 4}}>
                                <Text style={{"color": "#dc2626", "fontWeight": "700"}}>X</Text>
                            </Pressable>
                        </View>
                        if task["due"] != "" {
                            <Text style={{"marginTop": 8, "fontSize": 12, "color": "#475569"}}>{task["due"] as str}</Text>
                        }
                    </View>
                }
            }
        </View>
    </View>
}
