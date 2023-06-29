import type { NextPage } from 'next'
import type { CurriculumVitaeProperties, Education, Job } from '#components/cv'
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
      <div>
        <h2>Who am I?</h2>
        <p>{data.statement}</p>
      </div>
      <div>
        <h2>Work Experience</h2>
        <ul>
          {data.experience?.map((job) =>
            <li>
              <h3>{`${job.role} @ ${job.company} - ${job.city}, ${job.country}`}</h3>
              <dl>
                <dt>Type:</dt><dd>{job.type}</dd>
                <dt>Duration:</dt><dd>{`${job.start} - ${job.end}`}</dd>
              </dl>
              <p>{job.achievements}</p>
            </li>
          )}
        </ul>
      </div>
      <div>
        <h2>Education</h2>
        <ul>
          {data.education?.map((education: Education) =>
            <li>
              <h3>{`${education.school}`}</h3>
              <p>{`${education.grade}  (${education.start} - ${education.end})`}</p>
              <dl>
                {education.thesis && <><dt>Thesis:</dt><dd>{education.thesis}</dd></>}
                <dt>Cumulative GPA:</dt><dd>{education.gpa}/100</dd>
                <dt>Most relevant subjects and courses:</dt>
                <dd><ul>{education.subjects?.map((subject) => <li>{subject}</li>)}</ul></dd>
              </dl>
            </li>
          )}
        </ul>
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
