#!vanilla

# Test change

class $blab.d3Object

    constructor: (id) ->
        @element = d3.select "##{id}"
        @element.selectAll("svg").remove()
        @obj = @element.append "svg"
        @initAxes()
        
    append: (obj) -> @obj.append obj
    
    initAxes: ->

class $blab.LineChart extends $blab.d3Object

    constructor: (@spec) ->
                
        @id = @spec.id
        @container = $ "##{@id}"
        @x0 = @spec.x0 ? 100
        @y0 = @spec.y0 ? 50
        @width = @container.width() - @x0*2
        @height = @container.height() - @y0*2
        @xLabel = @spec.xLabel ? ""
        @yLabel = @spec.yLabel ? ""
        @background = @spec.background ? "#eee"
        
        super @id
                  
        @line = d3.svg.line()
            .x((d) => @xScale(d.x) + @x0)
            .y((d) => @yScale(d.y) + @y0)
        
        r = @append("rect")
            .attr("width", @width)
            .attr("height", @height)
            .style("fill", @background)
            .attr("transform", "translate(#{@x0}, #{@y0})")
            
        @append("g")
            .attr("class", "axis")
            .attr("transform", "translate(#{@x0}, #{@y0+@height})")
            .call(@xAxis)
        
        @append("text")
            .attr("text-anchor", "center")
            .attr("x", @x0+@width/2)
            .attr("y", @y0+@height+40)
            .text(@xLabel)
            
        @append("g")
            .attr("class", "axis")
            .attr("transform", "translate(#{@x0}, #{@y0})")
            .call(@yAxis)
        
        @append("text")
            .attr("text-anchor", "middle")
            .attr("x", @x0-70)
            .attr("y", @y0+@height/2)
            .text(@yLabel)
                   
        if @spec.click?
            click = (coords) =>
                [xm, ym] = coords
                x = @xScale.invert xm
                y = @yScale.invert ym
                @spec.click x, y
            r.on "click", -> click(d3.mouse this)
            
        @path = null
            
    plot: (x, y, color="blue", hold=false) ->
        @path.remove() if @path and not hold
        data = ({x: x[idx], y: y[idx]} for xp, idx in x)
        foundNaN = false
        for yp in y
            foundNaN = true if isNaN(yp) or Math.abs(yp)>1e10
        return if foundNaN
        @path = @append("path")
            .attr("d", @line(data))
            .attr("stroke", color)
            .attr("stroke-width", 2)
            .attr("fill", "none")
            # ZZZ id?
        
    initAxes: ->
        @xScale = d3.scale.linear()
            .domain(@spec.xLim ? [0, 1])
            .range([0, @width])
        @xAxis = d3.svg.axis()
            .scale(@xScale)
            .ticks(@spec.xTicks ? 10)
            .orient("bottom")
        @yScale = d3.scale.linear()
            .domain(@spec.yLim ? [0, 1])
            .range([@height, 0])
        @yAxis = d3.svg.axis()
            .scale(@yScale)
            .ticks(@spec.yTicks ? 10)
            .orient("left")
