#include "Nice.ch"

//----------------------------------------------------------------------------//
// Wrapper for Apache ECharts
//----------------------------------------------------------------------------//

CLASS TNiceChart FROM TNiceControl

    DATA hOption  INIT {=>}  // Harbour Hash for ECharts Option
    DATA nWidth   INIT 400
    DATA nHeight  INIT 300

    METHOD New( oParent, hOption, nWidth, nHeight )
    METHOD SetOption( hOption )
    METHOD SetTitle( cTitle )
    METHOD SetXAxis( aData )
    METHOD AddSeries( aData, cType, lSmooth, lArea )
    METHOD GetHtml()
    METHOD GetModelName()
    METHOD GetModelValue()
   
ENDCLASS

METHOD New( oParent, hOption, nWidth, nHeight ) CLASS TNiceChart

    ::hOption  := If( hOption != nil, hOption, {=>} )
    ::super:New( oParent )
   
    // Default Size or passed size
    ::nWidth   := If( nWidth != nil, nWidth, 600 )
    ::nHeight  := If( nHeight != nil, nHeight, 400 )

return Self

METHOD SetOption( hOption ) CLASS TNiceChart
    local cJson
    ::hOption := hOption
   
    // If we are already running (page loaded), we should update the chart
    if ::GetPage() != nil .and. ::GetPage():oWeb != nil
    cJson := If( ValType( ::hOption ) == "C", ::hOption, hb_jsonEncode( ::hOption ) )
    ::GetPage():oWeb:ScriptCallMethodArg( "updateChart", ::cId + ":" + cJson )
    endif
return nil

METHOD SetTitle( cTitle ) CLASS TNiceChart
    hb_HSet( ::hOption, "title", { "text" => cTitle } )
return nil

METHOD SetXAxis( aData ) CLASS TNiceChart
    hb_HSet( ::hOption, "xAxis", { "type" => "category", "data" => aData } )
    hb_HSet( ::hOption, "yAxis", { "type" => "value" } ) // Ensure yAxis exists
return nil

METHOD AddSeries( aData, cType, lSmooth, lArea ) CLASS TNiceChart
    local hSeries
    
    DEFAULT cType   := "line"
    DEFAULT lSmooth := .F.
    DEFAULT lArea   := .F.
    
    if ! hb_HHasKey( ::hOption, "series" )
    ::hOption[ "series" ] := {}
    endif
    
    hSeries := { "data" => aData, "type" => cType }
    if lSmooth
    hSeries[ "smooth" ] := .T.
    endif
    if lArea
    hSeries[ "areaStyle" ] := {=>}
    endif
    
    AAdd( ::hOption[ "series" ], hSeries )
return nil

METHOD GetModelName() CLASS TNiceChart
    // We define a reactive variable for the option, though ECharts is imperative.
    // We will use a mounted hook in the component or manual JS init.
    return "chart_" + ::cId
return nil

METHOD GetModelValue() CLASS TNiceChart
return "{}"

METHOD GetHtml() CLASS TNiceChart
    local cJson   := If( ValType( ::hOption ) == "C", ::hOption, hb_jsonEncode( ::hOption ) )
    local cHtml   := ""
   
    // We use a div with specific ID.
    // We inject a script to init the chart when mounted.
    // Note: In the global template, we should have a generic way to init charts.
    // For simpler implementation, we'll append a script tag that registers this chart.
   
    cHtml += '<div id="' + ::cId + '" style="width: ' + AllTrim(Str(::nWidth)) + 'px; height: ' + AllTrim(Str(::nHeight)) + 'px;"></div>'
   
    // We need to inject JS to initialize this specific chart.
    // Since Vue mounts first, we can use a small script that waits or pushes to a global list.
    // Let's assume window.charts is a global registry we created in NiceCore.
   
    cHtml += "<script>"
    cHtml += "  (function() {"
    cHtml += "    const initChart = () => {"
    cHtml += "      const chartDom = document.getElementById('" + ::cId + "');"
    cHtml += "      if(!chartDom) return;"
    cHtml += "      const myChart = echarts.init(chartDom);"
    cHtml += "      const option = " + cJson + ";"
    cHtml += "      myChart.setOption(option);"
    cHtml += "      window.charts['" + ::cId + "'] = myChart;"
    cHtml += "    };"
    // Retry logic if echarts isn't loaded yet? No, script is at bottom.
    // But DOM might not be ready if inside Vue template?
    // Vue lifecycle: We are injecting raw HTML into the slot.
    // We can try setTimeout to ensure DOM render.
    cHtml += "    setTimeout(initChart, 100);"
    cHtml += "  })();"
    cHtml += "</script>"
   
return cHtml
