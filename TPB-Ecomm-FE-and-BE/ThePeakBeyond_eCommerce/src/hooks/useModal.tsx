import { useState, useCallback } from 'react'
import { makeStyles, Theme, createStyles } from '@material-ui/core/styles'
import Modal from '@material-ui/core/Modal'
import Backdrop from '@material-ui/core/Backdrop'
import Fade from '@material-ui/core/Fade'

const useStyles = makeStyles((theme: Theme) =>
  createStyles({
    modal: {
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
    },
    paper: {
      backgroundColor: '#1a1b21',
      boxShadow: '0 25px 125px 20px rgb(0 0 0 / 95%)',
      padding: theme.spacing(2, 4, 3),
      borderRadius: '30px',
      maxHeight: '75vh',
      overflowY: 'scroll',
      margin: 20,
    },
  })
)

export const useModal = () => {
  const classes = useStyles()

  const [isOpen, setIsOpen] = useState(false)

  const showModal = useCallback(() => {
    setIsOpen(true)
  }, [])

  const hideModal = useCallback(() => {
    setIsOpen(false)
  }, [])

  const ModalContainer = ({ children }) => (
    <Modal
      aria-labelledby="transition-modal-title"
      aria-describedby="transition-modal-description"
      className={classes.modal}
      open={isOpen}
      onClose={hideModal}
      closeAfterTransition
      BackdropComponent={Backdrop}
      BackdropProps={{
        timeout: 500,
      }}
    >
      <Fade in={isOpen}>
        <div className={classes.paper}>{children}</div>
      </Fade>
    </Modal>
  )

  return { isOpen, showModal, hideModal, Modal: ModalContainer }
}
