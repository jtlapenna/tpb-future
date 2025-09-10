import { Grid, Typography, Link } from '@material-ui/core'
import { map } from 'lodash'
import { useHistory } from 'react-router-dom'
export const Home = ({ menuOnly = false }) => {
  const history = useHistory()
  const navigations = [
    { title: 'Products', link: '' },
    { title: 'Brands', link: '' },
    { title: 'Educations + Uses', link: '' },
    { title: 'Daily Deals', link: '' },
  ]

  return (
    <Grid container>
      {!menuOnly && (
        <Grid item xs={6} className="flex flex-center">
          <Typography variant="h2">
            Browse our <br />
            catalogue <br />
            to see what we <br />
            have <br />
            in stock
          </Typography>
        </Grid>
      )}

      <Grid item xs={menuOnly ? 12 : 6}>
        <ul className="db">
          {map(navigations, (link: any, index: number) => (
            <li className={`dib ${menuOnly ? 'w-100' : 'w-50'} white fadeIn`}>
              <div className="yellow m-16 p-32 br-24">
                <div className="title">0{index + 1}</div>
                <div
                  className={`${
                    menuOnly ? 'anim-ease-left' : 'mt-32'
                  } f32 text`}
                >
                  {link.title}
                </div>

                {!menuOnly && (
                  <Link
                    onClick={() => history.push('/products')}
                    className="mt-32 right"
                  >
                    <span className="button__text">{link.title}</span>
                    <span className="button__background"></span>
                  </Link>
                )}
              </div>
            </li>
          ))}
        </ul>
      </Grid>
    </Grid>
  )
}
