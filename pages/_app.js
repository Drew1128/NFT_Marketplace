import '../styles/globals.css'
import Link from 'next/link'


function myApp({ Component, pageProps }) {
  return (
    <div >
      <nav className="border-b p-6 bg-gradient-to-r from-sky-500 to-indigo-500">
        <p className="text-3xl text-white font-bold">Metaverse Marketplace</p>
        

        
        <div className="flex mt-4">
          <Link href="/">
            <a className="mr-4 text-blue-200">
              Home
            </a>
          </Link>
          <Link href="/create-item">
            <a className="mr-6 text-blue-200">
              Sell Digital Asset
            </a>
          </Link>
          <Link href="/my-assets">
            <a className="mr-6 text-blue-200">
              My Digital Assets
            </a>
          </Link>
          <Link href="/creator-dashboard">
            <a className="mr-6 text-blue-200">
              Creator Dashboard
            </a>
          </Link>
        </div>
      </nav>
      <Component {...pageProps} />
    </div>
  )
}

export default myApp