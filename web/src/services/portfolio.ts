import type { Curriculum } from '#components/cv/slice'

export async function getData(): Promise<{ data: Curriculum }> {
	const response = await fetch('https://api.zatara.in.dev', {
		method: 'GET',
		headers: {
			'Content-Type': 'application/json',
		},
	})
	const result = await response.json()
	response.headers.forEach((value, key) => console.log(key, ':', value))
	return result
}
