function! fern#scheme#file#mapping#project_top#init(disable_default_mappings) abort
  nnoremap <buffer><silent> <Plug>(fern-action-project-top) :<C-u>call <SID>call('project_top', 0)<CR>
  nnoremap <buffer><silent> <Plug>(fern-action-project-top:reveal) :<C-u>call <SID>call('project_top', 1)<CR>
endfunction

function! s:call(name, ...) abort
  return call(
        \ 'fern#mapping#call',
        \ [funcref(printf('s:map_%s', a:name))] + a:000,
        \)
endfunction

function! s:findroot(path, patterns) abort
  let l:path = a:path
  while 1
    for l:pattern in a:patterns
      let l:current = l:path . '/' . l:pattern
      if stridx(l:pattern, '*') != -1 && !empty(glob(l:current, 1))
        return l:path
      elseif l:pattern =~# '/$'
        if isdirectory(l:current)
          return l:path
        endif
      elseif filereadable(l:current)
        return l:path
      endif
    endfor
    let l:next = fnamemodify(l:path, ':h')
    if l:next == l:path || (has('win32') && l:next =~# '^//[^/]\+$')
      break
    endif
    let l:path = l:next
  endwhile
  return ''
endfunction

function! s:map_project_top(helper, reveal) abort
  let root = a:helper.sync.get_root_node()
  let path = s:findroot(root._path, g:findroot_patterns)
  if empty(path)
    throw 'No project top directory found'
  endif
  if a:reveal
    execute printf(
          \ 'Fern %s -reveal=%s',
          \ fnameescape(path),
          \ fnameescape(a:helper.sync.get_cursor_node()._path),
          \)
  else
    execute printf('Fern %s', fnameescape(path))
  endif
endfunction

let g:fern#scheme#file#mapping#project_top#disable_default_mappings =
      \ get(g:, 'fern#scheme#file#mapping#project_top#disable_default_mappings', 0)
