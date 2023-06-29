import { useCV } from '#hooks'

export interface AcademicProject {
	title: string,
	type: string,
	start?: Date,
	end?: Date,
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
	education?: object[],
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
