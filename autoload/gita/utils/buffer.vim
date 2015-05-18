let s:save_cpo = &cpo
set cpo&vim


" Private functions
function! s:open(name, group, ...) abort " {{{
  let config = get(a:000, 0, {})
  if empty(a:group)
    let B = gita#utils#import('Vim.Buffer')
    let opener = get(config, 'opener', 'edit')
    let loaded = B.open(a:name, opener)
    let bufnr = bufnr('%')
    return {
          \ 'loaded': loaded,
          \ 'bufnr': bufnr,
          \}
  else
    let vname = printf('_buffer_manager_%s', a:group)
    if !has_key(s:, vname)
      let BM = gita#utils#import('Vim.BufferManager')
      let s:{vname} = BM.new(config)
    endif
    let ret = s:{vname}.open(a:name, config)
    return {
          \ 'loaded': ret.loaded,
          \ 'bufnr': ret.bufnr,
          \}
  endif
endfunction " }}}
function! s:update(buflines) abort " {{{
  let saved_cursor = getpos('.')
  let saved_modifiable = &l:modifiable
  let saved_undolevels = &l:undolevels
  let &l:modifiable=1
  let &l:undolevels=-1
  silent %delete _
  call setline(1, a:buflines)
  call setpos('.', saved_cursor)
  let &l:modifiable = saved_modifiable
  let &l:undolevels = saved_undolevels
  setlocal nomodified
endfunction " }}}
function! s:clear_undo_history() abort " {{{
  let saved_undolevels = &undolevels
  let &undolevels = -1
  silent execute "normal a \<BS>\<ESC>"
  let &undolevels = saved_undolevels
endfunction " }}}
function! s:is_listed_in_tabpage(expr) abort " {{{
  let bufnum = bufnr(a:expr)
  if bufnum == -1
    return 0
  endif
  let buflist = tabpagebuflist()
  return string(bufnum) =~# printf('\v^%%(%s)$', join(buflist, '|'))
endfunction " }}}
function! s:bufname(name, ...) abort " {{{
  let sep = has('unix') ? ':' : '#'
  return join(['gita'] + a:000 + [a:name], sep)
endfunction " }}}


" Public functions
function! gita#utils#buffer#open(...) abort " {{{
  return call('s:open', a:000)
endfunction " }}}
function! gita#utils#buffer#update(...) abort " {{{
  return call('s:update', a:000)
endfunction " }}}
function! gita#utils#buffer#clear_undo_history(...) abort " {{{
  return call('s:clear_undo_history', a:000)
endfunction " }}}
function! gita#utils#buffer#is_listed_in_tabpage(...) abort " {{{
  return call('s:is_listed_in_tabpage', a:000)
endfunction " }}}
function! gita#utils#buffer#bufname(...) abort " {{{
  return call('s:bufname', a:000)
endfunction " }}}

let &cpo = s:save_cpo
" vim:set et ts=2 sts=2 sw=2 tw=0 fdm=marker:
