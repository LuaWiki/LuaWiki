@infobox(
  <%
    name         = Infobox
    bodystyle    = 
    title        = 测试信息框
    titlestyle   = 
    image        = {
      data    = [[File:example.png|200px]]
      caption = Caption for example.png
    }
    captionstyle = 
    headerstyle  = background:#ccf;
    labelstyle   = background:#ddf;
    datastyle    = 
    row1 = {
      header = 独自定义的顶栏
    }
    row2 = {
      label = 独自定义的标签
    }
    row3 = {
      data = 独自定义的数据
    }
    row4 = {
      header = 三项均有定义（顶栏）
      label = 三项均有定义（标签）——错误：因为有设顶栏而不会显示出来
      data = 三项均有定义（数据）——错误：因为有设顶栏而不会显示出来
    }
    row5 = {
      label = 标签和数据有定义（标签）
      data = 标签和数据有定义（数据）
    }
    below = {
      belowstyle = background:#ddf;
      data = 下方文本
    }
  %>
)