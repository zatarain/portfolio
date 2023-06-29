import { useCV } from '#hooks'

export interface Education {
	school: string,
	grade: string,
	thesis?: string,
	start: number,
	end: number,
	gpa: number,
	subjects?: string[],
}

export interface AcademicProject {
	title: string,
	type: string,
	start?: string,
	end?: string,
	duration?: string,
	description: string,
}

export interface CurriculumVitaeProperties {
	name: string,
	email?: string[],
	phone?: string[],
	social?: object[],
	website?: string,
	statement?: string,
	experience?: object[],
	education?: Education[],
	projects?: AcademicProject[],
	skills?: object[],
	awards?: string[],
	leadership?: string,
	volunteering?: string,
}

function CurriculumVitae() {
	const { data } = useCV()
	return (
		<div>
			<h1>{data.name}</h1>
		</div>
	)
}

export default CurriculumVitae
