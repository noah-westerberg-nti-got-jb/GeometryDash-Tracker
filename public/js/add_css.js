function add_css() {
    for (var path of arguments) {
        const css = document.createElement('link');
        css.rel = 'stylesheet';
        css.href = path;
        document.head.appendChild(css);
    }
}