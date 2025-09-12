import 'date-fns'
import React, {
  useState,
  useRef,
  MutableRefObject,
  useCallback,
  useEffect,
} from 'react'
import moment from 'moment'
import { makeStyles ,useTheme } from '@material-ui/core/styles'
import MomentUtils from '@date-io/moment'
import {
  MuiPickersUtilsProvider,
  KeyboardDatePicker,
} from '@material-ui/pickers'
import clsx from 'clsx'
import { BackButton } from 'components/_ui'
import {
  Box,
  Typography,
  FormGroup,
  FormControl,
  FormLabel,
  Link,
  Button,
  InputLabel,
  Input,
  useMediaQuery,
  Radio,
  FormControlLabel,
  RadioGroup,
} from '@material-ui/core'
import SignatureCanvas from 'react-signature-canvas'
import { useUserFacade } from 'state/user'
import { useCartFacade } from 'state/cart'
import { useModal } from 'hooks'
import {  httpGet } from 'services/http-client.service'
import * as TreezService from 'services/treez.service'
import { ITreezUser, ITreezCreateOrderRequest } from 'types'
import { TextWidget } from '../_ui'

const useStyles = makeStyles((theme)=>({
  cart: {
    padding: 50,
    marginRight:'300px',

    [theme.breakpoints.down('sm')]: {
      marginRight:0,
    },
  },
  cartHeading: {
    fontSize: '2.5em',
    color: 'white',
  },
  cartItem: {
    padding: '30px 0px',
    paddingRight: 90,
    position: 'relative',
  },
  cartItemImage: {
    width: 80,
    marginRight: 30,

    '& img': {
      borderRadius: '50%',
      aspectRatio: 1,
      minWidth:'80px',
      objectFit:'cover',
    },
  },
  cartItemName: {
    margin: 0,
    fontSize: 20,
    lineHeight: 1.4,
    color: 'white',
  },
  cartItemAmount: {
    marginTop: 0,
    marginBottom: 10,
    fontSize: 20,
    lineHeight: 1.4,
    color: 'rgba(255, 255, 255, 0.5) !important',
  },
  cartItemEdit: {
    color: '#00c796 !important',
    textDecoration: 'none',
    cursor: 'pointer',
    marginRight: '10px',

    '&:hover': {
      textDecoration: 'underline',
    },
  },
  cartItemPrice: {
    position: 'absolute',
    top: 30,
    right: 0,
    fontSize: 20,
    lineHeight: 1.4,
    fontWeight: 700,
    color: 'white',
  },
  cartItemSeparator: {
    display: 'block',
    position: 'absolute',
    left: 0,
    width: '100%',
    height: 1,
    background: 'rgba(255, 255, 255, 0.3)',

    '&.top': {
      top: 0,
    },
    '&.bottom': {
      bottom: 0,
    },
  },
  cartTotal: {
    padding: 15,
    position: 'absolute',
    right: '20px',
    bottom: '128px',
  },
  cartTotalPrice: {
    marginLeft: 60,
    textAlign: 'right',
    color: 'white',

    '& .price': {
      fontSize: 50,
    },

    '& .tax': {
      fontSize: 14,
      color: 'rgba(255, 255, 255, 0.3)',
    },
  },
  primaryButton: {
    backgroundColor: '#09c796 !important',
    fontSize: 20,
    color: 'white !important',
    borderRadius: 25,
    lineHeight: 1.1,
    padding: '15px 20px',
    margin: '0 5px',
    letterSpacing:'0.1em',
    fontFamily: 'mulibold !important',
  },
  secondaryButton: {
    backgroundColor: '#242B35 !important',
    fontSize: 20,
    color: 'white !important',
    borderRadius: 25,
    lineHeight: 1.1,
    padding: '15px 20px',
    margin: '0 5px',
    letterSpacing:'0.1em',
    fontFamily: 'mulibold !important',
  },
  cartItemEditInput: {
    color: 'white',
    width: '100px',
    marginRight: '10px',
  },
  fileUploadInputContainer: {
    '& label': {
      color: 'white',
      width: '300px',
      height: '200px',
      border: '1px solid white',
      display: 'flex',
      justifyContent: 'center',
      alignItems: 'center',
      textAlign: 'center',
      marginRight: '15px',
      cursor: 'pointer',
    },
  },
  fileUploadInput: {
    display: 'none',
  },
  fileUploadContainer: {
    display: 'flex',

    '& img': {
      width: '300px',
      height: '200px',
      objectFit: 'contain',
      marginRight: '15px',
    },
  },
  formGroup: {
    marginBottom: '30px',
    width: '300px',
  },
  formControl: {
    '& .MuiSvgIcon-root': {
      color: 'white',
    },
    '& .MuiFormLabel-root': {
      color: 'rgba(255, 255, 255, 0.3)',
      fontSize: '20px',
      transform: 'translate(0, 1.5px) scale(1)',
    },
    '& .MuiFormLabel-root.Mui-focused': {
      color: 'white',
      fontSize: '20px',
    },
    '& .MuiInputBase-input': {
      color: 'white',
      width: '300px',
      padding: '15px 5px',
    },

    '& .MuiButton-root': {
      width: '200px',
    },
  },
  termsModal: {
    color: 'white',
    maxWidth: 600,
    lineHeight: '1.3rem',
    '& input[type="checkbox"]': {
      width: '20px',
      height: '20px',
      margin: '0',
      marginRight: '10px',
      filter: 'hue-rotate(310deg)',
    },
  },
  signatureContainer: {
    marginTop: '30px',

    '& label': {
      fontWeight: 'bold',
      display: 'block',
      color: 'white !important',
    },
    '& .sigCanvas': {
      border: '1px solid white',
    },
    '& .clear': {
      color: 'white !important',
      textDecoration: 'underline !important',
      display: 'inline-block',
      float: 'right',
    },
  },
  termsTextArea: {
    width: 'calc(100% - 40px)',
    backgroundColor: 'transparent',
    overflowY: 'scroll',
    color: 'rgba(255, 255, 255, 0.8)',
    border: 'none',
    fontSize: '16px',
    height: '150px',
  },
  error: {
    fontSize: '14px',
    color: 'red',
    fontWeight: 'bold',
    marginTop: '10px',
  },
  signatureLabelContainer: {
    marginBottom: '10px',
  },
  signatureLabel: {
    display: 'inline-block',
  },
  termsCheckboxLabel: {
    fontSize: '.95em',
  },
  deliveryFormRow: {
    marginTop: 32,
    width: '100%',
  },
}))

export const Cart = () => {
  const classes = useStyles()
  const { cartState, totalPrice, addCart, removeCart, resetCart } =
    useCartFacade()
  //console.log({ cartState })
  const { userState } = useUserFacade()
  const {
    store: userStore,
    email,
    given_name: first_name,
    family_name: last_name,
    birthday,
    address,
  } = userState
  const {
    isOpen: isTermsModalOpen,
    showModal: showTermsModal,
    hideModal: hideTermsModal,
    Modal: TermsModal,
  } = useModal()

  const [deliveryAddress, setDeliveryAddress] = useState<any>({street:'',city:'',zip:'',country:'United States',state:''})
  const [editItem, setEditItem] = useState('')
  const [editItemCount, setEditItemCount] = useState(0)
  const [frontImage, setFrontImage] = useState<any>()
  const [backImage, setBackImage] = useState<any>()
  const [dlExpiryDate, setDlExpiryDate] = React.useState<Date | null>(
    new Date()
  )
  const [terms, setTerms] = useState<string>('')
  const theme = useTheme()
  const matchesMobile = useMediaQuery(theme.breakpoints.down('sm'))
  const [dlNumber, setDlNumber] = useState('')
  const [cartStep, setCartStep] = useState<
    'DL' | 'TERMS' | 'INITIAL' | 'CHECKOUT' | 'ORDERED' | 'DELIVERY'
  >('INITIAL')
  const [agreeWithTerms, setAgreeWithTerms] = useState(true)
  const [dlNumberError, setDlNumberError] = useState('')
  const [dlImagesError, setDlImagesError] = useState('')
  const [agreeWithTermsError, setAgreeWithTermsError] = useState('')
  const [signatureError, setSignatureError] = useState('')
  const [verificationStatus, setVerificationStatus] = useState('')
  const [treezUser, setTreezUser] = useState<ITreezUser>()
  const [orderStatus, setOrderStatus] = useState<'success' | 'fail' | string>()
  const [dlExpError, setDlExpError] = useState('')
  const [orderType,setOrderType] = useState<'PICKUP' | 'DELIVERY'>('PICKUP');
  const signatureCanvas = useRef() as MutableRefObject<HTMLDivElement>
  const agreeWithTermsRef = useRef() as MutableRefObject<HTMLInputElement>

  const getStoreName = ()=>{
    const stores = localStorage.getItem('USER_STORES');
    if(stores){
      const storeJson = JSON.parse(stores);

      if(userStore){
        return storeJson.find(c=>c.id === userStore)?.name;
      }
    }

    return '';
  }
  const handleFrontUploadClick = (event) => {
    setFrontImage(event.target.files[0])
  }

  const handleUploadID = async () => {
    setDlNumberError(dlNumber ? '' : 'Driver License Number is required')
    setDlImagesError(frontImage ? '' : 'Driver License Images are required')
    setDlExpError(dlExpiryDate ? '' : 'Driver License Expiration Date is required');

   if(!dlNumber || !dlExpiryDate){
    return;
   }

    if (dlNumber && frontImage) showTermsModal()
  }

  const handleOrderTypeChange = (event:any)=>{
    setOrderType(event.target.value)
  }

  const handleAcceptTerms = async () => {
    const agreed = agreeWithTermsRef.current.checked
    const signatureImg = (signatureCanvas.current as any)
      .getTrimmedCanvas()
      .toDataURL('image/png')
    setAgreeWithTermsError(
      !agreed ? 'You must agree with the Terms and Conditions' : ''
    )
    setSignatureError(
      (signatureCanvas.current as any).isEmpty()
        ? 'Please fill in your signature'
        : ''
    )
    if (agreed && !(signatureCanvas.current as any).isEmpty()) {

     
  const dlImagesFormData = new FormData()
    dlImagesFormData.append('files', frontImage)
    dlImagesFormData.append('customer_id', treezUser?.customer_id || '')
    dlImagesFormData.append('id', treezUser?.customer_id || '')
    dlImagesFormData.append('drivers_license', dlNumber)
    dlImagesFormData.append('phone', userState?.phone_number || '')
    dlImagesFormData.append(
      'drivers_license_expiration',
      moment(dlExpiryDate).format('YYYY-MM-DD')
    )

    await TreezService.uploadDocument(
      userStore,
      'DRIVERS_LICENSE',
      dlImagesFormData
    )

      hideTermsModal()
      setCartStep('CHECKOUT')
      handleCreateOrder()
    }
  }

  const nextStep = useCallback(() => {
    if (cartStep === 'INITIAL') setCartStep('DL')
    else if (cartStep === 'DL') setCartStep('TERMS')
  }, [setCartStep])

  const handleCheckout = async () => {
    if (email) {
      try {
        const findTreezUserResponse = await TreezService.findUserInTreez(
          userStore,
          email,
          first_name,
          last_name,
          moment(birthday, 'MM-DD-YYYY').format('YYYY-MM-DD'),
        )
        console.log(findTreezUserResponse)
        if (          
          findTreezUserResponse.resultCode === 'SUCCESS' &&
          findTreezUserResponse.data &&
          !findTreezUserResponse.data.length
        ) {
          console.log('Creating new user in Treez')
          const user = await TreezService.createUser(userStore, {
            email,
            first_name,
            last_name,
            birthday: moment(birthday, 'MM-DD-YYYY').format('YYYY-MM-DD'),
          })
          setTreezUser(user.data)
          setCartStep('DL')
        } else if (
          findTreezUserResponse.resultCode === 'SUCCESS' &&
          findTreezUserResponse.data &&
          findTreezUserResponse.data.length
        ) {
          setTreezUser(findTreezUserResponse.data[0])
          setVerificationStatus(
            findTreezUserResponse.data[0].verification_status
          )
          if (
            (findTreezUserResponse.data[0].verification_status === "VERIFIED") || (
            findTreezUserResponse.data[0].drivers_license && 
            findTreezUserResponse.data[0].drivers_license.length > 5)
          ) {
            handleCreateOrder();
          }else{
            setCartStep('DL')
          }
        }
      } catch (err) {
        console.log({ err })
      }
    }else{
      document.location.href="/login";
    }
  }


  const createOrder = async () =>{

    if(orderType === 'DELIVERY' && !deliveryAddress.street && !deliveryAddress.city 
    && !deliveryAddress.state && !deliveryAddress.zip){
      return;
    }

    console.log({ cartState });

    const requestBody: ITreezCreateOrderRequest = {
      customer_id: (treezUser ? treezUser.customer_id : ''),
      type: orderType,
      delivery_address:orderType === 'DELIVERY' ? deliveryAddress:null,
      items: cartState[userStore].items.map((item) => ({
        size_id: item.product.sku,
        quantity: item.count.toString(),
      })),
    }
    const response = await TreezService.createOrder(userStore, requestBody)
    if (response.resultCode === 'SUCCESS') {
      setOrderStatus('success');
      resetCart(userStore);
    } else {
      console.log(TreezService.compileOrderStatus(
        response.resultReason,
        response.resultDetail,
        cartState[userStore].items
      ));
      setOrderStatus('fail')
    }
    setCartStep('ORDERED')
  }

  const handleCreateOrder = () => {
    setCartStep('DELIVERY')
  }

  const setFormData = (value:string,key:string)=>{
    setDeliveryAddress({
      ...deliveryAddress,
      [key]:value,
    })
  }
  const increaseCount = ()=>{
    setEditItemCount(editItemCount+1);
  }

  const decreaseCount = ()=>{
    if(editItemCount-1<0){
      return;
    }
    setEditItemCount(editItemCount-1);
  }

  useEffect(() => {
    ;(async () => {
      if (userStore) {
        const result = await httpGet(`/store/terms/${userStore}`)
        if (result) setTerms(result.term || ``)
      }
    })()
  }, [userStore])

  return (
    <>
      
        <Box
            display="flex"
            alignItems="center"
            justifyContent="space-between"
            style={{marginTop:24,paddingLeft:50}}
          >
            {cartStep === 'INITIAL' ? (
              <BackButton />
            ):(
              <BackButton onClick={()=>setCartStep('INITIAL')} />
            )}
            
          </Box>
        
      {cartStep === 'DL' && (
        <div className={classes.cart + ' db'}>
         
          <Typography component="h1" className={classes.cartHeading}>
            Verify Your Identity
          </Typography>
          <Box>
            <FormGroup className={classes.formGroup}>
              <FormControl
                className={classes.formControl}
                style={{ maxWidth: '300px' }}
              >
                <InputLabel htmlFor="dl-number">
                  Driver License Number
                </InputLabel>
                <Input
                  id="dl-number"
                  aria-describedby="driver-license-number"
                  value={dlNumber}
                  onChange={(v) => setDlNumber(v.target.value)}
                />
              </FormControl>
              {dlNumberError && (
                <Typography component="p" className={classes.error}>
                  {dlNumberError}
                </Typography>
              )}
            </FormGroup>
            <FormGroup className={classes.formGroup}>
              <FormControl
                className={classes.formControl}
                style={{ maxWidth: '300px' }}
              >
                <MuiPickersUtilsProvider utils={MomentUtils}>
                  <KeyboardDatePicker
                    disableToolbar
                    variant="inline"
                    format="MM-DD-YYYY"
                    margin="normal"
                    id="date-picker-inline"
                    label="Driver License Expiration Date"
                    value={dlExpiryDate}
                    onChange={(date: any) => setDlExpiryDate(date ? date.toDate() : null)}
                    KeyboardButtonProps={{
                      'aria-label': 'change date',
                    }}
                  />
                </MuiPickersUtilsProvider>
              </FormControl>
              {dlExpError && (
                <Typography component="p" className={classes.error}>
                  {dlExpError}
                </Typography>
              )}
            </FormGroup>
            <FormGroup className={classes.formGroup}>
              <Box className={classes.fileUploadContainer}>
                {!frontImage ? (
                  <Box className={classes.fileUploadInputContainer}>
                    <input
                      accept="image/*"
                      id="contained-button-file"
                      type="file"
                      onChange={handleFrontUploadClick}
                      className={classes.fileUploadInput}
                    />
                    <label htmlFor="contained-button-file">
                      Click to upload the front image of your driver license
                    </label>
                  </Box>
                ) : (
                  <img
                    width="100%"
                    src={URL.createObjectURL(frontImage)}
                    alt="Driver license front image"
                    onClick={() => setFrontImage(null)}
                  />
                )}
              </Box>
              {dlImagesError && (
                <Typography component="p" className={classes.error}>
                  {dlImagesError}
                </Typography>
              )}
            </FormGroup>
            <FormGroup>
              <FormControl
                className={classes.formControl}
                style={{ maxWidth: '300px' }}
              >
                <Button
                  variant="contained"
                  className={classes.primaryButton + ' w-100'}
                  onClick={handleUploadID}
                >
                  Submit
                </Button>
              </FormControl>
            </FormGroup>
          </Box>
        </div>
      )}
      {
        <TermsModal>
          <Box className={classes.termsModal}>
            <h2>Terms And Conditions</h2>
            <div className={classes.termsTextArea}>{terms}</div>
            <Box className={classes.signatureContainer}>
              <div className={classes.signatureLabelContainer}>
                <FormLabel className={classes.signatureLabel}>
                  Draw Your Signature Here
                </FormLabel>
                <Link
                  href="#"
                  className="clear"
                  onClick={() => {
                    if (signatureCanvas && signatureCanvas.current)
                      (signatureCanvas.current as any).clear()
                  }}
                >
                  Clear
                </Link>
              </div>
              <SignatureCanvas
                penColor="green"
                canvasProps={{
                  width: 'calc(100vw-100)',
                  height: 100,
                  className: 'sigCanvas',
                }}
                ref={signatureCanvas}
              />
              {signatureError && (
                <Typography component="p" className={classes.error}>
                  {signatureError}
                </Typography>
              )}
            </Box>
            <Box mt="15px">
              <Box display="flex" alignItems="center">
                <input
                  type="checkbox"
                  id="agreeWithTerms"
                  name="agreeWithTerms"
                  ref={agreeWithTermsRef}
                />
                <label htmlFor="agreeWithTerms" className={classes.termsCheckboxLabel}>
                  I Agree With The Terms And Conditions
                </label>
              </Box>
              {agreeWithTermsError && (
                <Typography component="p" className={classes.error}>
                  {agreeWithTermsError}
                </Typography>
              )}
            </Box>
            <Box display="flex" justifyContent="space-evenly" mt="30px">
              <div className="w-100 center">
                <div className="dib w-50 center">
                  <Button
                    variant="contained"
                    className={classes.primaryButton + ' w-100'}
                    onClick={handleAcceptTerms}
                  >
                    OK
                  </Button>
                </div>
                <div className="dib">&nbsp;</div>
                <div className="dib  w-50 center">
                  <Button
                    variant="contained"
                    className={classes.secondaryButton + ' w-100'}
                    onClick={hideTermsModal}
                  >
                    Cancel
                  </Button>
                </div>
              </div>
            </Box>
          </Box>
        </TermsModal>
      }
      {cartStep === 'DELIVERY' && (
         <Box className={classes.cart} >
           <RadioGroup
              aria-label="gender"
              defaultValue={orderType}
              className="radio-group"
              onChange={handleOrderTypeChange}
            >
              <FormControlLabel value="PICKUP" className={classes.cartHeading} control={<Radio />} label="PICKUP AT&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" />
                <Typography component="h2" className="mt-16 ml-32">
                  {getStoreName()}
                </Typography>
                <FormControlLabel value="DELIVERY" className="mt-32" control={<Radio />} label="DELIVERY TO" />
              </RadioGroup>

              <FormGroup className={classes.formGroup} style={{minWidth:'500px'}}>
                <FormControl
                  className={classes.formControl}
                  style={{ maxWidth: '500px',marginTop:32 }}
                >
                  <InputLabel htmlFor="dl-number">
                    Street
                  </InputLabel>
                  <Input
                    fullWidth
                    onChange={(v) => setFormData(v.target.value,'street')}
                    value={deliveryAddress.street}
                    disabled={orderType === 'PICKUP'}
                  />
                  {!deliveryAddress.street && orderType === 'DELIVERY' && (
                    <Typography component="p" className={classes.error}>
                      Street is required!
                    </Typography>
                  )}
                </FormControl>
                <FormControl
                  className={classes.formControl}
                  style={{ maxWidth: '500px',marginTop:32 }}
                >
                  <InputLabel htmlFor="dl-number">
                    City
                  </InputLabel>
                  <Input
                    fullWidth
                    onChange={(v) => setFormData(v.target.value,'city')}
                    value={deliveryAddress.city}
                    disabled={orderType === 'PICKUP'}
                  />
                  {!deliveryAddress.city && orderType === 'DELIVERY' && (
                    <Typography component="p" className={classes.error}>
                      City is required!
                    </Typography>
                  )}
                </FormControl>

                <div className={`flex ${classes.deliveryFormRow}`}>
                  <div className="w-50 ml-0">
                    <FormControl
                      className={classes.formControl}
                      style={{ maxWidth: '80%'}}>
                      <InputLabel htmlFor="dl-number">
                          Zip
                        </InputLabel>
                        <Input
                          style={{width:'80%'}}
                          onChange={(v) => setFormData(v.target.value,'zip')}
                          value={deliveryAddress.zip}
                          disabled={orderType === 'PICKUP'}
                        />
                        
                        {!deliveryAddress.zip && orderType === 'DELIVERY' && (
                          <Typography component="p" className={classes.error}>
                            Zip is required!
                          </Typography>
                        )}

                      </FormControl>
                    </div>
                    <div className="w-50 ml-0">
                      <FormControl
                        className={classes.formControl}
                        style={{ maxWidth: '80%'}}>
                            <InputLabel htmlFor="dl-number" style={{position:'unset'}}>
                            State
                            </InputLabel>
                            <Input
                              style={{width:'80%',marginTop:0}}
                              onChange={(v) => setFormData(v.target.value,'state')}
                              value={deliveryAddress.state}
                              disabled={orderType === 'PICKUP'}
                            />
                            
                            {!deliveryAddress.state && orderType === 'DELIVERY' && (
                              <Typography component="p" className={classes.error}>
                                State is required!
                              </Typography>
                            )}
                        </FormControl>
                      </div>
                
                </div>
                <FormControl
                  className={classes.formControl}
                  style={{ maxWidth: '500px',marginTop:32 }}
                >
                  <InputLabel htmlFor="dl-number">
                  Country
                  </InputLabel>
                  <Input
                    value={deliveryAddress.country}
                    onChange={(v) => setFormData(v.target.value,'country')}
                    disabled={orderType === 'PICKUP'}
                  />
                </FormControl>
            </FormGroup>
            <Button
                variant="contained"
                className={classes.primaryButton}
                onClick={createOrder}
              >
                Submit
              </Button>
         </Box>
      )}
      {cartStep === 'INITIAL' && (
        <Box className={classes.cart}>
          <Typography component="h1" className={classes.cartHeading}>
            My Cart
          </Typography>
          {cartState &&
            cartState[userStore] &&
            cartState[userStore].items.map((item, index) => {
              const { product, count } = item
              return (
                <Box
                  display="flex"
                  className={classes.cartItem}
                  key={product.id}
                >
                  {index === 0 && (
                    <div className={clsx(classes.cartItemSeparator, 'top')} />
                  )}
                  <Box className={classes.cartItemImage}>
                    <img src={product.image_url} alt={product.name} />
                  </Box>
                  <Box>
                    <Typography component="p" className={classes.cartItemName}>
                      {product.name}
                    </Typography>
                    <Typography className={classes.cartItemAmount}>
                      ${product.min_price} x{' '}
                      {editItem === product.id ? (
                        <Box display="inline-flex">
                          <div className="db">
                            <div onClick={decreaseCount} className={`round-button ${editItemCount === 0 ? ' disabled':''}`}> - </div>
                            <div className="dib mr-16 white">{editItemCount} </div>
                            <div onClick={increaseCount} className="round-button"> + </div>
                          </div>
                         
                          <Link
                            href="#"
                            className={classes.cartItemEdit}
                            onClick={() => {

                              if(editItemCount === 0){
                                removeCart({product,count:0,storeId: userStore})
                              }else{
                                addCart({
                                  product,
                                  count: editItemCount - count,
                                  storeId: userStore,
                                })
                              }
                             
                              setEditItem('')
                            }}
                          >
                            Done
                          </Link>
                        </Box>
                      ) : (
                        count
                      )}
                    </Typography>

                    {editItem !== product.id && (
                      <Box display="flex">
                        <Link
                          href="#"
                          className={classes.cartItemEdit}
                          onClick={() => {
                            setEditItem(product.id)
                            setEditItemCount(count)
                          }}
                        >
                          EDIT
                        </Link>
                      </Box>
                    )}
                  </Box>
                  <Typography className={classes.cartItemPrice}>{`$${(
                    count * +product.min_price
                  ).toFixed(2)}`}</Typography>
                  <div className={clsx(classes.cartItemSeparator, 'bottom')} />
                </Box>
              )
            })}
          <Box
            display="flex"
            justifyContent="flex-end"
            className={classes.cartTotal}
          >
            <Box mt={2}>
              <TextWidget text="TOTAL" size={16} />
            </Box>
            <Box className={classes.cartTotalPrice}>
              <Typography className="price">
                ${cartState[userStore]?.totalPrice.toFixed(2) || 0}
              </Typography>
              <Typography component="p" className="tax">
                PRICES DO NOT INCLUDE TAX
              </Typography>
            </Box>
          </Box>
          {cartState[userStore]?.items.length > 0 && (
            <Box display="flex" mt={2} justifyContent="center" className="checkout-reset">
              <Button
                variant="contained"
                className={classes.secondaryButton}
                onClick={() => resetCart(userStore)}
              >
                Reset Cart
              </Button>
              <Button
                variant="contained"
                className={classes.primaryButton}
                onClick={handleCheckout}
              >
                Checkout
              </Button>
            </Box>
          )}
        </Box>
      )}
      {cartStep === 'ORDERED' &&
        (orderStatus === 'success' ? (
          <Typography component="h1" className={classes.cartHeading}>
            Your order has been submitted, please check your order status on the My Dashboard page.
          </Typography>
        ) : (
          <>
            <Typography component="h1" className={classes.cartHeading}>
            There is an issue with your order, please call us to finalize and submit your items.
            </Typography>
          </>
        ))}
    </>
  )
}
