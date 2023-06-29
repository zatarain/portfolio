import type { NextPage } from 'next'
import type { CurriculumVitaeProperties } from '#components/curriculum-vitae'
import CurriculumVitae from '#components/curriculum-vitae'
import PageLayout from '#components/PageLayout'

interface Properties {
  data: CurriculumVitaeProperties
}

export async function getServerSideProps() {
  const response = await fetch(process.env.API_URL || '')
  const data = await response.json()
  return {
    props: {
      data: {
        ...data,
        social: data.social || [],
        experience: data['work-experience'] || [],
        education: (data.education || []).map((education: any) => {
          return {
            ...education,
            subjects: education['relevant-subjects'] || [],
          }
        }),
        projects: data['academic-projects'] || [],
        skills: data['technical-skills'] || [],
      },
    },
  }
}

const HomePage: NextPage<Properties> = ({ data }) => {
  return (
    <PageLayout data={data}>
      <CurriculumVitae data={data} />
    </PageLayout>
  )
}

export default HomePage
