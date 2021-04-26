if exists('g:loaded_dice') | finish | endif " prevent loading file twice

let s:save_cpo = &cpo " save user coptions
set cpo&vim " reset them to defaults

" command to run our plugin
lua math.randomseed(os.time())
command! -nargs=1 Dice lua require'dice'.diceroll(<f-args>)
nnoremap rd :lua require'dice'.diceroll(vim.fn.expand('<cWORD>'))<CR>

let &cpo = s:save_cpo " and restore after
unlet s:save_cpo

let g:loaded_whid = 1

