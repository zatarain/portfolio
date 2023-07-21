import Image from 'next/image'

interface Properties {
	text: string,
}

const Loading = ({ text }: Properties) => {
	return (
		<>
			<Image src="https://i.gifer.com/VAyR.gif" alt={text} width={16} height={16} /> {text}
		</>
	)
}

export default Loading
