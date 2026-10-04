import from "@jac/runtime" { Outlet }

def:pub layout() -> JsxLayout {
    return (
        <div style={{"minHeight": "100vh"}}>
            <Outlet />
        </div>
    );
}
