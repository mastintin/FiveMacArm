document.addEventListener('DOMContentLoaded', () => {
    const navItems = document.querySelectorAll('.nav-item');
    const viewer = document.getElementById('md-viewer');
    const breadcrumb = document.getElementById('breadcrumb');

    // Configuración de Marked.js
    marked.setOptions({
        highlight: function(code, lang) {
            if (Prism.languages[lang]) {
                return Prism.highlight(code, Prism.languages[lang], lang);
            }
            return code;
        },
        breaks: true,
        gfm: true
    });

    async function loadMarkdown(path) {
        viewer.innerHTML = '<div class="loader">Cargando documentación...</div>';
        try {
            const response = await fetch(path);
            if (!response.ok) throw new Error('No se pudo cargar el archivo');
            const text = await response.text();
            
            // Renderizar Markdown
            viewer.innerHTML = marked.parse(text);
            
            // Resaltado de código
            Prism.highlightAllUnder(viewer);

            // Scroll al inicio
            viewer.scrollTop = 0;
        } catch (error) {
            viewer.innerHTML = `<div class="error">Error: ${error.message}</div>`;
        }
    }

    navItems.forEach(item => {
        item.addEventListener('click', (e) => {
            e.preventDefault();
            
            // Actualizar UI
            navItems.forEach(i => i.classList.remove('active'));
            item.classList.add('active');
            
            // Actualizar Breadcrumb
            const group = item.closest('.nav-group').querySelector('.group-title').textContent;
            breadcrumb.textContent = `Documentación / ${group} / ${item.textContent}`;

            // Cargar MD
            const mdPath = item.getAttribute('data-md');
            loadMarkdown(mdPath);
        });
    });

    // Cargar página inicial
    const initialItem = document.querySelector('.nav-item.active');
    if (initialItem) {
        loadMarkdown(initialItem.getAttribute('data-md'));
    }
});
