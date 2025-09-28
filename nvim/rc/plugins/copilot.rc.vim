let g:copilot_enabled = v:true

function! ToggleCopilot()
    if g:copilot_enabled
        let g:copilot_enabled = v:false
        echo "copilot disabled"
    else
        let g:copilot_enabled = v:true
        echo "copilot enabled"
    endif
endfunction

