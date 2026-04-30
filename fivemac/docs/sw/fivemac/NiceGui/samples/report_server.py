from nicegui import ui
import datetime

@ui.page('/report')
def report_page():
    # Use Tailwind for a "Premium" look
    with ui.column().classes('w-full max-w-4xl mx-auto p-12 bg-white'):
        # Header
        with ui.row().classes('w-full justify-between items-center border-b-2 border-indigo-500 pb-4 mb-8'):
            ui.label('INFORME DE SIMULACIÓN').classes('text-3xl font-bold text-indigo-900')
            ui.label(datetime.datetime.now().strftime('%d/%m/%Y')).classes('text-gray-500')
        
        # User Info Card
        with ui.card().classes('w-full mb-8 bg-indigo-50'):
            with ui.column().classes('p-4'):
                ui.label('DATOS DEL CANDIDATO').classes('text-sm font-bold text-indigo-700 mb-2')
                with ui.row().classes('gap-12'):
                    with ui.column():
                        ui.label('Nombre:').classes('text-xs text-gray-500')
                        ui.label('MANUEL GARCÍA').classes('font-bold')
                    with ui.column():
                        ui.label('Edad:').classes('text-xs text-gray-500')
                        ui.label('63 años').classes('font-bold')
                    with ui.column():
                        ui.label('Estado:').classes('text-xs text-gray-500')
                        ui.label('ACTIVO').classes('text-green-600 font-bold')

        # Results Table
        ui.label('RESUMEN DE RESULTADOS').classes('text-xl font-bold text-gray-800 mb-4')
        columns = [
            {'name': 'concept', 'label': 'Concepto', 'field': 'concept', 'align': 'left'},
            {'name': 'val_a', 'label': 'Escenario A', 'field': 'val_a'},
            {'name': 'val_b', 'label': 'Escenario B', 'field': 'val_b'},
        ]
        rows = [
            {'concept': 'Base Reguladora', 'val_a': '2.415,17 €', 'val_b': '2.380,40 €'},
            {'concept': 'Porcentaje Aplicado', 'val_a': '100%', 'val_b': '98,40%'},
            {'concept': 'Pensión Bruta', 'val_a': '2.415,17 €', 'val_b': '2.342,31 €'},
        ]
        ui.table(columns=columns, rows=rows, row_key='concept').classes('w-full shadow-md rounded-lg')

        # Chart Placeholder (representing an EChart)
        ui.label('PROYECCIÓN DE PENSIÓN').classes('text-xl font-bold text-gray-800 mt-8 mb-4')
        with ui.row().classes('w-full h-48 bg-gray-100 rounded-lg items-center justify-center border-2 border-dashed border-gray-300'):
            ui.label('Aquí iría un gráfico de ECharts real').classes('text-gray-400 italic')

        # Footer
        ui.label('Este documento ha sido generado automáticamente por XlsJubila Bridge Engine.').classes('text-xs text-gray-400 mt-12 text-center w-full')

ui.run(port=8080, show=False)
