" NeoBundleInit
let $VIMBUNDLE = '~/.vim/bundle'
let $NEOBUNDLEPATH = $VIMBUNDLE . '/neobundle.vim'
if stridx(&runtimepath, $NEOBUNDLEPATH) != -1
" If the NeoBundle doesn't exist.
command! NeoBundleInit try | call s:neobundle_init()
            \| catch /^neobundleinit:/
                \|   echohl ErrorMsg
                \|   echomsg v:exception
                \|   echohl None
                \| endtry

function! s:neobundle_init()
    redraw | echo "Installing neobundle.vim..."
    if !isdirectory($VIMBUNDLE)
        call mkdir($VIMBUNDLE, 'p')
        echo printf("Creating '%s'.", $VIMBUNDLE)
    endif
    cd $VIMBUNDLE

    if executable('git')
        call system('git clone git://github.com/Shougo/neobundle.vim')
        if v:shell_error
            throw 'neobundleinit: Git error.'
        endif
    endif

    set runtimepath& runtimepath+=$NEOBUNDLEPATH
    call neobundle#rc($VIMBUNDLE)
    try
        echo printf("Reloading '%s'", $MYVIMRC)
        source $MYVIMRC
    catch
        echohl ErrorMsg
        echomsg 'neobundleinit: $MYVIMRC: could not source.'
        echohl None
        return 0
    finally
        echomsg 'Installed neobundle.vim'
    endtry

    echomsg 'Finish!'
endfunction

autocmd! VimEnter * redraw
            \ | echohl WarningMsg
            \ | echo "You should do ':NeoBundleInit' at first!"
            \ | echohl None
endif

" plugin setup -- NeoBundle 
filetype plugin indent off

if has('vim_starting')
  set runtimepath+=~/.vim/bundle/neobundle.vim/
  call neobundle#rc(expand('~/.vim/bundle/'))
endif

call neobundle#begin(expand('~/.vim/bundle/'))

" Let NeoBundle manage NeoBundle
NeoBundleFetch 'Shougo/neobundle.vim'

NeoBundle 'scrooloose/nerdtree'
NeoBundle 'Shougo/vinarise.vim'

call neobundle#end()

filetype plugin indent on

NeoBundleCheck
