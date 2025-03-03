<p align="center">
   <img src="./djist.png" alt="djist plugin for neovim"/>
</p>

# djist.nvim
A collection of Django niceties for Neovim. (Mostly based off of [django-extensions](https://github.com/django-extensions/django-extensions).)

It currently offers following functionalities:
- `showViewURLS` - A Flask like *view* of your views where the URLs corresponding to a view are shown on the side of the view. Only supports class based views for now. Example:
```python
class ForumList(...) /forums/
...                  ^^^^^^^^
...
```
![djist-working](https://user-images.githubusercontent.com/42387090/138939490-5570784b-50cd-46e4-8a4a-3d4877b31c07.gif)


## Install

Install using your favorite plugin manager.
For example, if you use `vim-plug`, put:
```
Plug 'pulsar17/djist'
```
in your `vimrc`, then `:PlugInstall` the plugin.

## Usage
The `DJANGO_SETTINGS_MODULE` environment variable must be set to the correct settings module before running this plugin. This can be done by setting it while launching Neovim as follows:
```sh
$ DJANGO_SETTINGS_MODULE='<myproject>.settings' nvim
```

**Note**: Neovim must be started at the project root, as `djist` adds the current working directory to Python's `sys.path` so the settings module can be imported. Starting the editor at the project root is a good practice anyways.

### For `showViewURLS`
Go anywhere inside the view and run `:lua require'djist'.showViewURLS()`

## Inner Workings
### For `showViewURLS`
- `djist` first parses the current buffer and extracts the name of the view using `treesitter`.
- After that `djist` detects the current virtual environment(using the `VIRTUAL_ENV` environment variable).
- Then it launches the venv's Python interpreter with a script and provides the `viewName` as one of the arguments.
- The script then finds the corresponding URLs for the view and prints them on its stdout which is monitored by `djist` (stdout is actually created and passed to the Python process by `djist`)
- The launching of Python and monitoring of stdout is asynchronous, thanks to `luvit` (`libuv` bindings for Lua) provided by Neovim.
