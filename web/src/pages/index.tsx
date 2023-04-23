import type { NextPage } from 'next'
import Head from 'next/head'

import { useCV } from '#hooks'
import PageLayout from '#components/PageLayout'


const IndexPage: NextPage = () => {
  console.log(typeof (fetch))
  const { data } = useCV()

  return (
    <PageLayout title="CV" data={data}>
      <p>This is the homepage</p>
    </PageLayout>
  )
}

export default IndexPage
