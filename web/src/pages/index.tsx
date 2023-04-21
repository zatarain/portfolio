import type { NextPage } from 'next'
import Head from 'next/head'

import { useCV } from '#hooks'
import styles from '#styles/Home.module.css'

const IndexPage: NextPage = () => {
  console.log(typeof (fetch))
  const { data } = useCV()

  return (
    <div className={styles.container}>
      <Head>
        <title>{data && data.name}</title>
        <link rel="icon" href="/favicon.ico" />
      </Head>
      <header className={styles.header}>
        <img src="/logo.svg" className={styles.logo} alt="logo" />
        <h1>{data && data.name}</h1>
      </header>
    </div>
  )
}

export default IndexPage
