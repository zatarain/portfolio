import type { NextPage } from 'next'
import Head from 'next/head'
import CurriculumVitae from '#components/cv'

const IndexPage: NextPage = () => {
  return (
    <>
      <Head>
        <title>CV - Ulises Tirado Zatarain</title>
        <link rel="icon" href="/favicon.ico" />
      </Head>
      <header>
        <div>test hot reload</div>
        <CurriculumVitae />
      </header>
    </>
  )
}

export default IndexPage
