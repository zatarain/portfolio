import type { NextPage } from 'next'
import type { CurriculumVitaeProperties } from '#components/cv'
import PageLayout from '#components/PageLayout'

interface Properties {
  data: CurriculumVitaeProperties
}

export async function getServerSideProps() {
  const response = await fetch(process.env.API_URL || '')
  const data = await response.json()
  return {
    props: {
      data,
    },
  }
}

const HomePage: NextPage<Properties> = ({ data }) => {
  return (
    <PageLayout data={data}>
      <p>This is the homepage</p>
    </PageLayout>
  )
}

export default HomePage
