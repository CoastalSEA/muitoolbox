            function paste_text(src,~)
                %callback function to paste the contents of the clipboard 
                %to a uicontrol (src)
                src.String = clipboard('paste');
            end 