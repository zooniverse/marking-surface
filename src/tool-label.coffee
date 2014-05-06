class ToolLabel extends ToolControls
  tag: 'div.marking-surface-tool-label'

  setContent: (html) ->
    @el?.innerHTML = html

ToolLabel.defaultStyle = insertStyle 'marking-surface-tool-label-default-style', '''
  .marking-surface-tool-label {
    background: rgba(0, 0, 0, 0.5);
    border-radius: 3px;
    color: white;
    padding: 3px 10px;
    pointer-events: none;
    position: absolute;
    white-space: nowrap;
  }

  .marking-surface-tool-label:not([data-selected]) {
    display: none;
  }

  .marking-surface-tool-label[data-out-of-bounds] {
    display: none;
  }
'''
