import styles from './index.module.css'

interface Properties {
	data: {
		name: string
	}
}

const Header = ({ data }: Properties) => {
	return (
		<header className={styles.header}>
		</header>
	)
}

export default Header
