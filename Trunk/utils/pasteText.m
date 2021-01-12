            function pasteText(src,~)
                %paste the contents of the clipboard to the equation box
                src.String = clipboard('paste');
            end 