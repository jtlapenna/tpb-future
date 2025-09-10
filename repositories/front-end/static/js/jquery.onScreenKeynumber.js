;(function($) {
  $.fn.onScreenKeynumber = function(options) {
    var settings = $.extend(
      {
        draggable: false,
        topPosition: '20%',
        leftPosition: '30%'
      },
      options
    )
    var $keyboardTriggers = this
    var $input = $()
    var $keyboardNumber = renderKeyboard('osk-container-number')
    var $keys = $keyboardNumber.children('li')
    var $backspaceKey = $keyboardNumber.children('li.osk-backspace')
    var browserInPercent = $backspaceKey.css('marginRight').indexOf('%') > -1

    function activateInput($input) {
      $keys.removeClass('osk-disabled')
      $keyboardTriggers.removeClass('osk-focused')
      $input.addClass('osk-focused').focus()
      positionKeyboard($input)
    }

    function fixWidths() {
      var $key = $()
      var keyboardWidth = $keyboardNumber.width()
      var totalKeysWidth = 0
      var difference
      if (browserInPercent) {
        $keys.each(function() {
          $key = $(this)
          if (!$key.hasClass('osk-dragger') && !$key.hasClass('osk-space')) {
            totalKeysWidth +=
              $key.width() +
              Math.floor(
                (parseFloat($key.css('marginRight')) / 100) * keyboardWidth
              )
            if ($key.hasClass('osk-last-item')) {
              difference = keyboardWidth - totalKeysWidth
              if (difference > 0) {
                $key.width($key.width() + difference)
              }
              difference = 0
              totalKeysWidth = 0
            }
          }
        })
      }
    }

    // eslint-disable-next-line no-undef
    if (settings.draggable && jQuery.ui) {
      $keyboardNumber.children('li.osk-dragger').show()
      $keyboardNumber.css('paddingTop', '0').draggable({
        containment: 'document',
        handle: 'li.osk-dragger'
      })
    }

    function positionKeyboard($input) {
      var rect = $input[0].getBoundingClientRect()
      var scrollTop = window.pageYOffset || document.documentElement.scrollTop
      var scrollLeft = window.pageXOffset || document.documentElement.scrollLeft
      var additionalOffset = 60

      // Find the parent container
      var $parentContainer = $input.closest('.checkout')

      // Set the width of the keyboard to the width of the parent container
      if ($parentContainer.length) {
        var parentWidth = $parentContainer.width()
        $keyboardNumber.css('width', parentWidth + 'px')
      }

      $keyboardNumber.css(
        'top',
        rect.bottom + scrollTop + additionalOffset + 'px'
      )
      $keyboardNumber.css('left', rect.left + scrollLeft + 'px')
    }

    fixWidths()

    $keyboardNumber.hide().css('visibility', 'visible')

    $(window).resize(function() {
      fixWidths()
    })

    $keyboardTriggers.click(function() {
      $input = $(this)
      activateInput($input)
      $keyboardNumber.fadeIn('fast')
    })

    $keyboardNumber.off('click', 'li')
    $keyboardNumber.on('click', 'li', function() {
      var $key = $(this)
      var character = $key.html()
      var inputValue

      if ($key.hasClass('osk-dragger') || $key.hasClass('osk-disabled')) {
        $input.focus()
        return false
      }

      if ($key.hasClass('osk-hide')) {
        $keyboardNumber.fadeOut('fast')
        $input.blur()
        $keyboardTriggers.removeClass('osk-focused')
        return false
      }

      if ($key.hasClass('osk-backspace')) {
        inputValue = $input.val()
        $input.val(inputValue.substr(0, inputValue.length - 1))
        $input.trigger('keyup')
        return false
      }

      if ($key.hasClass('osk-number')) {
        character = $('span:visible', $key).html()
      }

      $input.focus().val($input.val() + character)
      $input.trigger('keyup')
    })

    return this
  }

  function renderKeyboard(keyboardId) {
    var $keyboardNumber = $('#' + keyboardId)

    if ($keyboardNumber.length) {
      return $keyboardNumber
    }

    $keyboardNumber = $(
      '<ul id="' +
        keyboardId +
        '">' +
        '<li class="osk-dragger osk-last-item">:&thinsp;:</li>' +
        '<li class="osk-number">' +
        '<span class="osk-off">1</span>' +
        '</li>' +
        '<li class="osk-number">' +
        '<span class="osk-off">2</span>' +
        '</li>' +
        '<li class="osk-number">' +
        '<span class="osk-off">3</span>' +
        '</li>' +
        '<li class="osk-number">' +
        '<span class="osk-off">4</span>' +
        '</li>' +
        '<li class="osk-number">' +
        '<span class="osk-off">5</span>' +
        '</li>' +
        '<li class="osk-number">' +
        '<span class="osk-off">6</span>' +
        '</li>' +
        '<li class="osk-number">' +
        '<span class="osk-off">7</span>' +
        '</li>' +
        '<li class="osk-number">' +
        '<span class="osk-off">8</span></li>' +
        '<li class="osk-number">' +
        '<span class="osk-off">9</span>' +
        '</li>' +
        '<li class="osk-number">' +
        '<span class="osk-off">0</span>' +
        '</li>' +
        '<li class="osk-backspace osk-last-item">backspace</li>' +
        '</ul>'
    )

    $('body').append($keyboardNumber)

    return $keyboardNumber
  }
  // eslint-disable-next-line no-undef
})(jQuery)
