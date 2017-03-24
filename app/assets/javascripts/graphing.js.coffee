# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$(document).bind 'mobileinit', ->
  $.mobile.ajaxLinksEnabled = false
  $.mobile.ajaxFormsEnabled = false
  $.mobile.ajaxEnabled = false
  return

$(document).ready ->
  window.charts = []
  i = 0
  num_charts = $(".chart").length
  while i < num_charts
    chart = new Highcharts.Chart(
      chart:
        renderTo: "chart_container_" + i
        type: "spline"
        zoomType: "x"

      title:
        text: "Individual Summary"

      xAxis:
        type: "datetime"
        maxZoom: 14 * 24 * 3600000
        title:
          text: "Weeks"

      legend:
        labelFormatter: ->
          @name

      yAxis:
        min: 0
        title:
          text: "Average Perceived Effort"

      series: [{}]
    )
    window.charts[i] = chart
    i++
  true

$ ->
  $(".project_select").change ->
    console.log 'Here I am!'
    subject_select = $(this).parents("form").find("#subject")
    unit_of_analysis = $(this).parents("form").find("#unit_of_analysis").val()
    assessment_id = $(this).val()
    for_research = $("#for_research").val()
    url = "subjects/" + unit_of_analysis + "/" + assessment_id + "/" + for_research
    $.getJSON url, (data) ->
      i = undefined
      newOption = undefined
      $(subject_select).empty()
      newOption = "<option value=\"-1\">None Selected</option>"
      $(subject_select).append newOption
      i = 0
      while i < data.subjects.length
        newOption = "<option value=" + data.subjects[i][1] + ">" + data.subjects[i][0] + "</option>"
        $(subject_select).append newOption
        i++
    $(subject_select).selectmenu 'refresh', true

  $("#for_research").change ->
    for_research = $("#for_research").val( )
    $("[id$='_panel']").each ->
      subject_select = $(this).parents("form").find("#subject")
      chart_num = parseInt($(this).find(".chart").attr("chart_num"))
      detail_container = $(this).find("#detail_container")
      unit_of_analysis = $(this).find("#unit_of_analysis").val()
      assessment = $(this).find("#assessment").val()
      subject = $(this).find("#subject").val()
      data_processing = $(this).find("#data_processing").val()
      if assessment isnt "-1"
        url = "subjects/" + unit_of_analysis + "/" + assessment + "/" + for_research
        $.getJSON url, (data) ->
          i = undefined
          newOption = undefined
          $(subject_select).empty()
          $(subject_select).refresh
          i = 0
          while i < data.subjects.length
            newOption = "<option value=" + data.subjects[i][1] + ">" + data.subjects[i][0] + "</option>"
            $(subject_select).append newOption
            i++
          $(subject_select).selectmenu 'refresh', true
        if subject isnt "-1"
          url = "data/" + unit_of_analysis + "/" + subject + "/" + assessment + "/" + data_processing + "/" + for_research
          window.charts[chart_num].showLoading()
          $.getJSON url, (data) ->
            chart = window.charts[chart_num]
            index = 0
            chart.series[index].remove()  while index < chart.series.length
            chart.setTitle
              text: data.details.name
            ,
              text: "Individual Data"
  
            index = 0
            while index < data.series.length
              chart.addSeries
                name: data.series[index].label
                data: data.series[index].data
  
              index++
            
            #Now let's handle the html bits
            key_arr = Object.keys(data.details)
            index = 0
            text = "<h3>Details and Statistics:</h3><UL>"
            while index < key_arr.length
              text += "<LI>" + key_arr[index] + ":" + data.details[key_arr[index]] + "</LI>"
              index++
            text += "</ul>"
            $(detail_container).html text
            chart.hideLoading()
  
  $(".submitting_select").change ->
    chart_num = parseInt($(this).parents("form").find(".chart").attr("chart_num"))
    detail_container = $(this).parents("form").find("#detail_container")
    unit_of_analysis = $(this).parents("form").find("#unit_of_analysis").val()
    assessment = $(this).parents("form").find("#assessment").val()
    subject = $(this).parents("form").find("#subject").val()
    data_processing = $(this).parents("form").find("#data_processing").val()
    for_research = $("#for_research").val()
    if subject isnt "-1"
      url = "data/" + unit_of_analysis + "/" + subject + "/" + assessment + "/" + data_processing + "/" + for_research
      window.charts[chart_num].showLoading()
      $.getJSON url, (data) ->
        chart = window.charts[chart_num]
        index = 0
        chart.series[index].remove()  while index < chart.series.length
        chart.setTitle
          text: data.details.name
        ,
          text: "Individual Data"
  
        index = 0
        while index < data.series.length
          chart.addSeries
            name: data.series[index].label
            data: data.series[index].data
  
          index++
        
        #Now let's handle the html bits
        key_arr = Object.keys(data.details)
        index = 0
        text = "<h3>Details and Statistics:</h3><UL>"
        while index < key_arr.length
          text += "<LI>" + key_arr[index] + ":" + data.details[key_arr[index]] + "</LI>"
          index++
        text += "</ul>"
        $(detail_container).html text
        chart.hideLoading()
  
  
  
