import $ from 'jquery'

export const ScreenKeyboardEvents = {
  mounted: function() {
    this.hideScreenKeyboard()
  },
  methods: {
    hideScreenKeyboard: function() {
      $(document).on('click', e => {
        // get keyboard elements
        const keyboard = $('#osk-container')
        const keyboardNumber = $('#osk-container-number')
        const inputForm = $('input')

        // Check if the click target is not an input or part of the keyboards
        if (
          !inputForm.is(e.target) &&
          !keyboard.is(e.target) &&
          !keyboard.has(e.target).length &&
          !keyboardNumber.is(e.target) &&
          !keyboardNumber.has(e.target).length
        ) {
          keyboard.fadeOut('fast')
          keyboardNumber.fadeOut('fast')
        } else {
          // Handle clicks on specific input types
          if (e.target.classList.contains('input-osk')) {
            keyboardNumber.fadeOut('fast')
            keyboard.fadeIn('fast')
          } else if (e.target.classList.contains('input-phone')) {
            keyboard.fadeOut('fast')
            keyboardNumber.fadeIn('fast')
          }
        }
      })
    }
  }
}

export default ScreenKeyboardEvents
