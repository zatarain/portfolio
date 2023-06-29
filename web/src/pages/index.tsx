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
      data: {
        name: data.name || '',
        social: data.social || [],
        website: data.website || '',
        statement: data.statement || '',
        experience: data['work-experience'] || [],
        education: data.education || [],
        projects: data['academic-projects'] || [],
        skills: data['technical-skills'] || [],
        awards: data.awards || [],
        leadership: data.leadership || '',
        volunteering: data.volunteering || '',
      },
    },
  }
}

const HomePage: NextPage<Properties> = ({ data }) => {
  return (
    <PageLayout data={data}>
      <div>
        <h2>Who am I?</h2>
        <p>{data.statement}</p>
      </div>
      <div>
        <h2>Major Academic Projects</h2>
        <ul>
          {data.projects?.map((project) =>
            <li>
              <h3>{project.title}</h3>
              <dl>
                <dt>Type:</dt><dd>{project.type}</dd>
                <dt>Duration:</dt><dd>{project.duration && project.duration || `${project.start} - ${project.end}`}</dd>
              </dl>
              <p>{project.description}</p>
            </li>
          )}
        </ul>
      </div>
      <div>
        <h2>Awards</h2>
        <ul>
          {data.awards?.map((award) => <li>{award}</li>)}
        </ul>
      </div>
      <div>
        <h2>Leadership</h2>
        {data.leadership}
      </div>
      <div>
        <h2>Volunteering Activities</h2>
        {data.volunteering}
      </div>
    </PageLayout>
  )
}

export default HomePage
