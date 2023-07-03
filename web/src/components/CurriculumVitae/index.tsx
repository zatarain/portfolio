import Markdown from '#components/Markdown'
import styles from './index.module.css'
export interface Job {
	role: string
	type: string
	company: string
	city: string
	country: string
	start: string
	end: string
	contributions: string
}

export interface Education {
	school: string
	grade: string
	thesis?: string
	start: number
	end: number
	gpa: number
	subjects?: string[]
}

export interface AcademicProject {
	title: string
	type: string
	start?: string
	end?: string
	duration?: string
	description: string
}

export interface CurriculumVitaeProperties {
	name: string
	email?: string[]
	phone?: string[]
	social?: object[]
	website?: string
	statement?: string
	experience?: Job[]
	education?: Education[]
	projects?: AcademicProject[]
	skills?: object[]
	awards?: string[]
	leadership?: string
	volunteering?: string
	tex?: string
}

interface Properties {
	data: CurriculumVitaeProperties
}

const CurriculumVitae = ({ data }: Properties) => {
	return (
		<div className={styles.curriculum}>
			<section id="personal-statement" className={styles.statement}>
				<h2>Who am I?</h2>
				<p>{data.statement}</p>
			</section>
			<section id="work-experience" className={styles.experiences}>
				<h2>Work Experience</h2>
				<ul>
					{data.experience?.map((job: Job, index: number) =>
						<li key={index}>
							<h3>{`${job.role} @ ${job.company} - ${job.city}, ${job.country}`}</h3>
							<dl>
								<dt>Type:</dt><dd>{job.type}</dd>
								<dt>Duration:</dt><dd>{`${job.start} - ${job.end}`}</dd>
							</dl>
							<Markdown content={job.contributions} />
						</li>
					)}
				</ul>
			</section>
			<section id="education" className={styles.education}>
				<h2>Education</h2>
				<ul>
					{data.education?.map((education: Education, index: number) =>
						<li key={index}>
							<h3>{`${education.school}`}</h3>
							<p>{`${education.grade} (${education.start} - ${education.end})`}</p>
							<dl>
								{education.thesis && <><dt>Thesis:</dt><dd>{education.thesis}</dd></>}
								<dt>Cumulative GPA:</dt><dd>{education.gpa}/100</dd>
								<dt className={styles.subjects}>Most relevant subjects and courses:</dt>
								<dd><ul>{education.subjects?.map((subject, key) => <li key={key}>{subject}</li>)}</ul></dd>
							</dl>
						</li>
					)}
				</ul>
			</section>
			<section id="academic-projects" className={styles.experiences}>
				<h2>Major Academic Projects</h2>
				<ul>
					{data.projects?.map((project: AcademicProject, index: number) =>
						<li key={index}>
							<h3>{project.title}</h3>
							<dl>
								<dt>Type:</dt><dd>{project.type}</dd>
								<dt>Duration:</dt><dd>{project.duration && project.duration || `${project.start} - ${project.end}`}</dd>
							</dl>
							<Markdown content={project.description} />
						</li>
					)}
				</ul>
			</section>
			<section id="awards">
				<h2>Awards</h2>
				<ul>
					{data.awards?.map((award: string, index: number) => <li key={index}>{award}</li>)}
				</ul>
			</section>
			<section id="leadership">
				<h2>Leadership</h2>
				<Markdown content={data.leadership} />
			</section>
			<section id="volunteering">
				<h2>Volunteering Activities</h2>
				<Markdown content={data.volunteering} />
			</section>
			<section>
				<h2>TeX</h2>
				<Markdown content={data.tex} />
			</section>
		</div>
	)
}

export default CurriculumVitae
